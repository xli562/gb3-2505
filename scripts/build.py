#!/home/xl562/anaconda3/envs/gb3/bin/python
# PYTHON_ARGCOMPLETE_OK

import subprocess, argcomplete, argparse, shutil
from pathlib import Path
from utils.xlogging import get_logger, set_logging_level
from utils.parse import find_most_recent_match, parse_sw_dir
from utils.run_process import run_make


logger = get_logger()
set_logging_level('DEBUG')

if __name__ == '__main__':
    current_dir = Path(__file__).parent
    project_root_docker = Path('/gb3-2505')
    software_dir_docker = project_root_docker / 'software'
    rtl_dir_docker = project_root_docker / 'hardware' / 'rtl'
    build_dir_docker = project_root_docker / 'build'
    processor_dir = current_dir.parent / 'hardware' / 'rtl' / 'processor'

    parser = argparse.ArgumentParser(description='Build software / hardware')
    parser.add_argument('--sw', '--software',
                        type    =str,
                        choices =parse_sw_dir(current_dir),
                        required=True,
                        help    ='Name of software')
    parser.add_argument('-t', '--time',
                        type    =str,
                        required=False,
                        default ='',
                        help    ='Source timestamp (yymmdd-hh-mm-ss). Accepts e.g. dhms28191520, hm1915. Uses newest file when ambiguous.')
    parser.add_argument('--src', '--source',
                        type    =str,
                        choices =['s', 'h', 'sh'],
                        required=False,
                        default ='sh',
                        help    ='SW only (outputs .hex), HW only (requires .hex), or SW & HW')
    parser.add_argument('-v', '--verbose',
                        type    =bool,
                        required=False,
                        default =False,
                        help    ='Show unfiltered makefile output')
    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    if args.src == 's':
        if args.time != '':
            logger.warning(f'Ignoring "--time {args.time}" for software-only build')
        commands = [f'make sw={args.sw} clean',
                    f'make sw={args.sw}',
                    f'make sw={args.sw} install']
        run_make(current_dir, software_dir_docker, commands, args.verbose)
    elif args.src == 'h':
        program_hex, data_hex = find_most_recent_match(current_dir.parent / 'build' / args.sw, args.time)
        program_hex = build_dir_docker / args.sw / program_hex
        data_hex = build_dir_docker / args.sw / data_hex
        logger.debug(f'Using program = {program_hex.name}')
        logger.debug(f'Using data    = {data_hex.name}')
        hex_dst_dir = processor_dir / 'verilog'
        subprocess.run(f'rm -f {processor_dir}/programs/*.hex', shell=True, check=True)
        subprocess.run(f'rm -f {processor_dir}/verilog/*.hex', shell=True, check=True)
        breakpoint()
        shutil.copy(program_hex, hex_dst_dir / 'program.hex')
        shutil.copy(data_hex, hex_dst_dir / 'data.hex')
        commands = ['make hw=processor clean-hw',
                    'make hw=processor']
        run_make(current_dir, rtl_dir_docker, commands, args.verbose)
    elif args.src == 'sh':
        if args.time != '':
            logger.warning(f'Ignoring "--time {args.time}" for en-suite build')
        commands = [f'make sw={args.sw} clean',
                    f'make sw={args.sw}',
                    f'make sw={args.sw} install']
        run_make(current_dir, software_dir_docker, commands, args.verbose)
        program_hex, data_hex = find_most_recent_match(current_dir.parent / 'build' / args.sw, args.time)
        program_hex = build_dir_docker / args.sw / program_hex
        data_hex = build_dir_docker / args.sw / data_hex
        logger.debug(f'Using program = {program_hex.name}')
        logger.debug(f'Using data    = {data_hex.name}')
        hex_dst_dir = processor_dir / 'verilog'
        subprocess.run(f'rm -f {processor_dir}/programs/*.hex', shell=True, check=True)
        subprocess.run(f'rm -f {processor_dir}/verilog/*.hex', shell=True, check=True)
        breakpoint()
        shutil.copy(program_hex, hex_dst_dir / 'program.hex')
        shutil.copy(data_hex, hex_dst_dir / 'data.hex')
        commands = ['make hw=processor clean-hw',
                    'make hw=processor']
        run_make(current_dir, rtl_dir_docker, commands, args.verbose)
