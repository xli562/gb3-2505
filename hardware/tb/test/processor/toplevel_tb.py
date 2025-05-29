import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from tqdm import tqdm

from utils.cocotb_logging import color_log

@cocotb.test()
async def test_toplevel_simple_1(dut):
    """ Minimal test of toplevel """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.OSCInst0.CLKHF, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    for cycle in tqdm(range(21956000)):
        await RisingEdge(dut.clk_i)
        if dut.led_o.value == 0b00000011 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_o.value == 0b00000111:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}', color='r')
            break
    
    color_log(dut, f'Total clock count: {dut.clk_i.value}')
    color_log(dut, f'Benchmark clock count: {end_cycle-start_cycle}')