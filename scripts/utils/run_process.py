import subprocess, re, sys
from pathlib import Path
from utils.xlogging import get_logger


logger = get_logger()

FILTER_PATTERNS = {
    r'^mv program\.hex':'Generated program.hex',
    r'^mv data\.hex.': 'Generated data.hex'
}

def run_and_filter(cmd, patterns, verbose=False):
    compiled = [(re.compile(p), alias) for p, alias in patterns.items()]
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )
    for raw_line in process.stdout:
        if verbose:
            print(raw_line, end='')
        else:
            for regex, desc in compiled:
                if regex.search(raw_line):
                    logger.debug(desc)           # the matching description

    process.wait()
    if process.returncode != 0:
        raise subprocess.CalledProcessError(process.returncode, cmd)

def run_make(current_dir:Path, makefile_dir:Path, commands:list[str], verbose=False):
    """ Runs Makefile in docker """

    project_root = current_dir.parent
    docker_image = 'ghcr.io/f-of-e/gb3-tools:latest'
    logger.debug(project_root)
    mount_spec = f"{project_root}:/gb3-2505"
    internal = ' && '.join(commands)

    docker_cmd = [
        'docker', 'run', '--rm',
        '-v', mount_spec,
        '-w', str(makefile_dir),
        docker_image,
        '/bin/bash', '-c', internal
    ]

    print('Running:', ' '.join(docker_cmd))
    try:
        run_and_filter(docker_cmd, FILTER_PATTERNS, verbose=verbose)
    except subprocess.CalledProcessError as e:
        print(f"Error: Build failed with exit code {e.returncode}", file=sys.stderr)
        sys.exit(e.returncode)