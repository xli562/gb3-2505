import cocotb
from cocotb.clock import Timer

@cocotb.test()
async def test_adder_simple_1(dut):
    """ Simple test of branch_decide """

    async def apply_inputs(branch, predicted, branch_enable, jump):
        dut.branch.value = branch
        dut.predicted.value = predicted
        dut.branch_enable.value = branch_enable
        dut.jump.value = jump
        await Timer(1, units="ns")

    # Case 1: Correct prediction, no jump
    await apply_inputs(branch=1, predicted=1, branch_enable=1, jump=0)
    assert dut.mispredict.value == 0
    assert dut.decision.value == 1
    assert dut.branch_jump_trigger.value == 0

    # Case 2: Misprediction (predicted taken, but not taken)
    await apply_inputs(branch=0, predicted=1, branch_enable=1, jump=0)
    assert dut.mispredict.value == 1
    assert dut.decision.value == 0
    assert dut.branch_jump_trigger.value == 0

    # Case 3: Not predicted, but taken
    await apply_inputs(branch=1, predicted=0, branch_enable=1, jump=0)
    assert dut.mispredict.value == 0
    assert dut.decision.value == 1
    assert dut.branch_jump_trigger.value == 1

    # Case 4: Jump overrides everything
    await apply_inputs(branch=0, predicted=0, branch_enable=0, jump=1)
    assert dut.mispredict.value == 0
    assert dut.decision.value == 0
    assert dut.branch_jump_trigger.value == 1

    # Case 5: Nothing active
    await apply_inputs(branch=0, predicted=0, branch_enable=0, jump=0)
    assert dut.mispredict.value == 0
    assert dut.decision.value == 0
    assert dut.branch_jump_trigger.value == 0
