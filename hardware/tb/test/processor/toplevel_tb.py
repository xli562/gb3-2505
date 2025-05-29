import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from tqdm import tqdm

@cocotb.test()
async def test_toplevel_simple_1(dut):
    """ Minimal test of toplevel """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.OSCInst0.CLKHF, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    # Apply inputs
    for _ in tqdm(range(21956000)):
        await RisingEdge(dut.clk_i)

    print(dut.clk_i.value)