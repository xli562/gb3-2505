import cocotb
from cocotb.clock import Timer

@cocotb.test()
async def test_adder_simple_1(dut):
    """ Minimal test 1 of adder """

    # Apply inputs
    dut.input1.value = 1
    dut.input2.value = 1
    await Timer(1, units="ns")
    
    assert dut.out.value == 2

@cocotb.test()
async def test_adder_simple_2(dut):
    """ Minimal test 2 of adder """

    # Apply inputs
    dut.input1.value = 3
    dut.input2.value = 0
    await Timer(1, units="ns")

    assert dut.out.value == 3