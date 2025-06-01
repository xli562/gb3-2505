#!/home/xl562/anaconda3/envs/gb3/bin/python
# PYTHON_ARGCOMPLETE_OK

""" This automation script is probably only necessary if testbenching
gets too tedious, which is not the case for now. """

import subprocess, argcomplete, argparse, shutil
from pathlib import Path
from utils.xlogging import get_logger, set_logging_level
from utils.parse import match_time, parse_sw_dir
from utils.run_process import run_make


logger = get_logger()
set_logging_level('DEBUG')

if __name__ == '__main__':
    pass
    # parse args
    # --src t: run from most recent or previous sw, --time optional
    # --src st: build sw into hex and run tb based on that
    # 