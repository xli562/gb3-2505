import cocotb
from cocotb.clock import Timer
from utils.cocotb_logging import color_log
from utils.randgen import generate_random_hex

@cocotb.test()
async def test_instruction_memory_simple(dut):
    """ Simple test of instruction_memory """

    for i in range(10):
    # for i in generate_random_hex(32, (0, 2**32-1), 10):
        # Apply inputs
        dut.addr.value = i
        await Timer(1, units="ns")
        
        color_log(dut, f'Input : {dut.addr.value}')
        color_log(dut, f'Output: {dut.out.value}')