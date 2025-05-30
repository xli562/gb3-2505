#!/home/xl562/anaconda3/envs/gb3/bin/python
# PYTHON_ARGCOMPLETE_OK

import subprocess, os, sys, re, argcomplete, argparse
from pathlib import Path
from utils.xlogging import get_logger, set_logging_level
from utils.strparse import find_most_recent_match

logger = get_logger()
set_logging_level('DEBUG')

FILTER_PATTERNS = {
    r'^mv\s+data\.hex\b':'Finished.'
}


def run_and_filter_output(cmd, patterns):
    compiled = [(re.compile(p), alias) for p, alias in patterns.items()]
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )
    for raw_line in process.stdout:
        for regex, desc in compiled:
            if regex.search(raw_line):
                logger.debug(desc)           # the matching description
                line = raw_line.strip()
                if line:
                    print(line)
                break
    process.wait()
    if process.returncode != 0:
        raise subprocess.CalledProcessError(process.returncode, cmd)


def parse_sw_dir(current_dir:Path):
    sw_dir = current_dir.parent / 'software'
    subdirs = []
    for item in os.listdir(sw_dir):
        if item not in ('Makefile', 'old', 'include'):
            subdirs.append(item)

    return subdirs  

def run_make(current_dir, commands):
    """ Runs Makefile in docker """
    # Locate project root
    project_root = os.path.abspath(os.path.join(current_dir, os.pardir))

    # Docker image and mount
    docker_image = 'ghcr.io/f-of-e/gb3-tools:latest'
    mount_spec = f"{project_root}:/gb3-2505"

    # Commands to run inside the container
    makefile_dir = '/gb3-2505/software'
    
    internal = ' && '.join(commands)

    # Full Docker command
    docker_cmd = [
        'docker', 'run', '--rm',
        '-v', mount_spec,
        '-w', makefile_dir,
        docker_image,
        '/bin/bash', '-c', internal
    ]

    # Print and execute
    print('Running:', ' '.join(docker_cmd))
    try:
        run_and_filter_output(docker_cmd, FILTER_PATTERNS)
    except subprocess.CalledProcessError as e:
        print(f"Error: Build failed with exit code {e.returncode}", file=sys.stderr)
        sys.exit(e.returncode)

if __name__ == '__main__':
    current_dir = Path(__file__).parent
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
    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    if args.src == 's':
        if args.time != '':
            logger.warning(f'Ignoring "--time {args.time}" for software-only build')
        commands = [f'make sw={args.sw} clean',
                    f'make sw={args.sw}',
                    f'make sw={args.sw} install']
        run_make(current_dir, commands)
    elif args.src == 'h':
        program_hex, data_hex = find_most_recent_match(current_dir.parent / 'build' / args.sw, args.time)
        logger.debug(f'Using program = {program_hex.name}')
        logger.debug(f'Using data    = {data_hex.name}')
        subprocess.run(f'rm -f {processor_dir}/programs/*.hex', shell=True, check=True)
        subprocess.run(f'rm -f {processor_dir}/verilog/*.hex', shell=True, check=True)
        run_make()#TODO: 2025-05-28
