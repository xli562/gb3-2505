import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from mods.logging_mods import *
from mods.quantization_mods import *


@cocotb.test()
async def test_letters(dut):
    """ Letting the dut run freely after receiving inputs A to H,
    respectively. """

    # Start the clock
    clock = Clock(dut.clk_i, 20, units='ns')
    cocotb.start_soon(clock.start())

    # Reset the DUT
    dut.rstn_i.value = 0
    dut.send_i.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk_i)
    dut.rstn_i.value = 1
    await RisingEdge(dut.clk_i)
    for _ in range(2):
        await RisingEdge(dut.clk_i)

    dut.send_i.value = 1
    for sw in range(8):
        # Apply inputs
        dut.parallel_i.value = int(11)

        for _ in range(dut.HALF_CLK_FREQ.value * 80):
            await RisingEdge(dut.clk_i)
