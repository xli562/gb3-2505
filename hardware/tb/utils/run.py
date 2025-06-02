import sys, shutil, re
from pathlib import Path
from datetime import datetime
from os import getenv, environ
from cocotb.runner import get_runner

from utils.xlogging import get_logger, set_logging_level


logger = get_logger()
set_logging_level('DEBUG')


compute_unit_name = 'processor'

def _move_waveform_file(test_dir:str, module_under_test:str) -> str:
    """ Moves the waveform file into tb/test/waves, 
    and renames it as e.g. 240923_110745_terminate """

    filename = datetime.now().strftime('%y%m%d_%H_%M_%S_') + module_under_test + '.fst'
    shutil.move(test_dir / compute_unit_name / 'dump.fst', test_dir.parent / 'waves' / filename)

def _update_defines(defines_path, output_dir):
    """ Parse Verilog `define`s (including bin/dec/hex literals) into a Python dict
    and pickle it to `pickle_path`.

    :param defines_path: path to your .v/.vh file
    :param output_dir: where to write the pickled dict (wb)

    :returns: dict {DEFINE_NAME: int or raw string}
    """
    with open(defines_path, 'r') as f:
        text = f.read()

    # Remove comments
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    text = re.sub(r'//.*',       '', text)

    params = {}
    for line in text.splitlines():
        line = line.strip()
        m = re.match(r'`define\s+(\w+)\s+(.+)', line)
        if not m:
            continue

        name, val = m.group(1), m.group(2).strip()

        # 3) match e.g. 3'b101
        nm = re.match(r"(\d+)'([bBdDhH])([0-9A-Fa-f_]+)", val)
        if nm:
            base = {'b':2,'B':2,'d':10,'D':10,'h':16,'H':16}[nm.group(2)]
            digits = nm.group(3).replace('_', '')
            val = int(digits, base)
        else:
            try:
                val = int(val)
            except ValueError:
                logger.warning(f'Unrecognisable value {val} in includes file.')

        params[name] = val

    with open(output_dir / 'defines.py', 'w') as f:
        f.writelines(['# This file is updated for each run, by runner._update_defines\n'])
        f.writelines([f'{name} = {val}\n' for name, val in params.items()])

    return params

def _single_test(
    test_id:int,                        # Test identifier
    dependencies:list[str],             # List of dependencies
    top_module:str,                     # Top module name
    test_module:str,                    # Cocotb test module name
    module_params:dict,                 # Parameters for the module
    module_path:Path,                   # Path to the module file
    component_path:Path,                # Path to the component files
    sim_build_dir:Path,                 # Working directory for the test
    test_files_dir:Path,                # Directory with the python testbench files
    extra_build_args:list[str] = [],    # Extra build arguments for the build process
    seed:int                   = None,  # Random seed for the test
    enable_trace:bool          = False, # Enable waveform trace
    skip_build:bool            = False, # Skip the build process if True
):
    logger.info(f"# ---------------------------------------")
    logger.info(f"# Test {test_id}")
    logger.info(f"# ---------------------------------------")
    logger.info(f"# Parameters:")
    logger.info(f"# - {'Test Index'}: {test_id}")
    for param_name, param_value in module_params.items():
        logger.info(f"# - {param_name}: {param_value}")
    logger.info("# ---------------------------------------")
    
    # Gather all Verilog files in the module directory and its subdirectories
    verilog_sources = [str(p) for p in Path(module_path).parent.glob('**/*.v')]
    logger.debug(f"Verilog sources:")
    for source in verilog_sources:
        logger.debug(source)
    
    # Add the test files' directory to Python's sys.path
    sys.path.append(str(test_files_dir))
    logger.debug(f"Added to Python path: {test_files_dir}")
    
    # Set environment variables to control file output locations
    environ['PYTHONPYCACHEPREFIX'] = str(sim_build_dir / '__pycache__')
    environ['GMON_OUT_PREFIX'] = str(sim_build_dir)
    
    # Initialize the Verilator simulation runner
    runner = get_runner(getenv("SIM", "verilator"))
    # Build the simulation unless skipping the build
    if not skip_build:
        try:
            runner.build(
                verilog_sources=verilog_sources,
                includes       =dependencies,
                hdl_toplevel   =top_module,
                parameters     =module_params,
                build_dir      =sim_build_dir,
                waves          =enable_trace,
                build_args     =[
                    "-Wno-GENUNNAMED",
                    "-Wno-WIDTHEXPAND",
                    "-Wno-WIDTHTRUNC",
                    "-Wno-UNOPTFLAT",
                    "-prof-c",
                    "--assert",
                    "--stats",
                    "-O2",
                    "-build-jobs",
                    "8",
                    "-Wno-fatal",
                    "-Wno-lint",
                    "-Wno-style",
                    '--trace-fst',
                    '-DSIMULATION',
                    *extra_build_args,]
            )
        except Exception as build_error:
            logger.error(f"Error occurred during build: {build_error}")
            return {
                "num_tests": 0,
                "failed_tests": 1,
                "params": module_params,
                "error": str(build_error)
            }

    # Run the test
    try:
        runner.test(
            hdl_toplevel     =top_module,
            hdl_toplevel_lang="verilog",
            test_module      =test_module,
            seed             =seed,
            results_xml      =str(sim_build_dir / "results.xml"),
            build_dir        =sim_build_dir,
            test_dir         =str(test_files_dir),
            waves            =enable_trace
        )
        
        # Move profiling output if it exists
        gmon_src = test_files_dir / "gmon.out"
        if gmon_src.exists():
            shutil.move(str(gmon_src), str(sim_build_dir / "gmon.out"))
        
    except Exception as build_error:
        logger.error(f"Error occurred while running Verilator simulation: {build_error}")

def run(module_under_test:str, current_dir:Path, enable_trace:bool):
    """ Runs the test.
     
    :param module_under_test: (str) name of module under test
    :param current_dir: (pathlib.Path) e.g., ./hardware/tb
    :param enable_trace: (bool) toggles tracing (test is slower with trace)
    """
    # Locate directories
    project_dir   = current_dir.parent        # ./hardware
    source_dir    = project_dir / 'rtl' / compute_unit_name / 'verilog'
    include_dir   = project_dir / 'rtl' / compute_unit_name / 'include'
    test_dir      = current_dir / 'test'
    sim_build_dir = current_dir / 'sim_build'

    # Update defines
    _update_defines(include_dir / 'rv32i-defines.v', current_dir / 'utils')

    # Remove previous sim_build.* and waveform dump
    dump_vcd = Path(test_dir / compute_unit_name / 'dump.vcd')
    dump_fst = Path(test_dir / compute_unit_name / 'dump.fst')
    dump_vcd.unlink(missing_ok=True)
    dump_fst.unlink(missing_ok=True)
    for item in current_dir.glob('sim_build.*'):
        if item.is_file():
            item.unlink()
        elif item.is_dir():
            shutil.rmtree(item)
    try:
        shutil.rmtree(test_dir / compute_unit_name / 'verilog' / 'program.hex')
        shutil.rmtree(test_dir / compute_unit_name / 'verilog' / 'data.hex')
        logger.debug('Removed both previous hex files')
    except:
        pass
    logger.debug('Removed all previous sim_build.* files/directories.')
    
    # Ensure sim_build_dir exists
    sim_build_dir.mkdir(parents=True, exist_ok=True)
    (test_dir / compute_unit_name / 'verilog').mkdir(parents=True, exist_ok=True)

    # Copy program.hex and data.hex into tb/test/processor/verilog
    shutil.copy(source_dir / 'program.hex', test_dir / compute_unit_name / 'verilog')
    shutil.copy(source_dir / 'data.hex', test_dir / compute_unit_name / 'verilog')

    module_params = {}
    dependencies = [compute_unit_name, include_dir, source_dir]


    _single_test(
        test_id       =1,
        dependencies  =dependencies,
        top_module    =f'{module_under_test}',
        test_module   =f'{module_under_test}_tb',
        module_params =module_params,
        module_path   =project_dir / 'rtl' / compute_unit_name / 'verilog' / f'{module_under_test}.v',
        component_path=project_dir / 'rtl' / compute_unit_name,
        sim_build_dir =sim_build_dir,
        test_files_dir=test_dir / compute_unit_name,
        enable_trace  =enable_trace,
    )
    
    if enable_trace:
        _move_waveform_file(test_dir, module_under_test)
