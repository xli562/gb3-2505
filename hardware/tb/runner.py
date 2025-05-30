#!/home/xl562/anaconda3/envs/gb3/bin/python
# PYTHON_ARGCOMPLETE_OK

import argcomplete, argparse
from pathlib import Path

from utils.run import run
from utils.xlogging import get_logger, set_logging_level


compute_unit_name = 'processor'

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='GB3 Cocotb Verilator runner')
    parser.add_argument('-n', 
                        type=str,
                        choices = ['adder', 'alu_control'],
                        required=True, 
                        help='Name of module being tested')
    parser.add_argument('-t', type=int, required=True, help='Trace waveform')
    argcomplete.autocomplete(parser)
    args = parser.parse_args()
    module_under_test = args.n
    enable_trace = bool(args.t)

    current_dir   = Path(__file__).parent     # ./hardware/tb

    run(module_under_test, current_dir, enable_trace)
