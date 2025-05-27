import cocotb
from cocotb.clock import Timer

@cocotb.test()
async def test_adder_simple(dut):
    """ Simple test of adder """

    # Apply inputs
    dut.input1.value = 1
    dut.input2.value = 2
    await Timer(1, units="ns")
    
    assert dut.out.value == 3
