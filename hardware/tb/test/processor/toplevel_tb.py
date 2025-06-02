import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from tqdm import tqdm

from utils.cocotb_logging import color_log


# @cocotb.test()
async def test_dhry(dut):
    """ Prints non-zero words in instruction mem """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.clk_i, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    for cycle in tqdm(range(30)):
        await RisingEdge(dut.clk_i)

        # for word in dut.inst_mem.instruction_memory.value:
        #     if word != 0:
        #         color_log(dut, word)

        color_log(dut, dut.led_reg.value)
        # Count cycles
        if dut.led_reg.value == 0b00000001 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_reg.value == 0b00000111:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}')
            # break


# @cocotb.test()
async def test_mem(dut):
    """ Prints non-zero words in instruction mem """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.clk_i, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    for cycle in range(5):
        await RisingEdge(dut.clk_i)

        for word in dut.inst_mem.instruction_memory.value:
            if word != 0:
                color_log(dut, word)

        # Count cycles
        if dut.led_o.value == 0b00000010 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_o.value == 0b00000001:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}', color='r')
            break

@cocotb.test()
async def test_toplevel_branch_predict_0(dut):
    """ Measures branch prediction performance """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.clk_i, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    branch_count = mispredict_count = 0
    # Rising edge detection variables
    branch = last_branch = 0
    prediction = last_prediction = 0
    actual = last_actual = 0
    is_predicted = False
    for cycle in tqdm(range(1279000)):
        await RisingEdge(dut.clk_i)

        # Count branches
        branch = dut.processor.branch_predictor_FSM.branch_mem_sig.value
        if (branch != last_branch):
            branch_count += branch
        # Count predictions
        prediction = dut.processor.branch_predictor_FSM.prediction.value
        actual = dut.processor.branch_predictor_FSM.actual_branch_decision.value
        if (prediction != last_prediction) and prediction == 1:
            if is_predicted == True:
                mispredict_count += 1
            is_predicted = True
        if (actual != last_actual) and actual == 1:
            if is_predicted == False:
                mispredict_count += 1
            is_predicted = False
        last_prediction = prediction
        last_actual = actual

        # Count cycles
        if dut.led_o.value == 0b00000010 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_o.value == 0b00000001:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}')
            break
    
    color_log(dut, f'Total branching instructions: {branch_count}')
    color_log(dut, f'Mispredicted branches: {mispredict_count}')
    color_log(dut, f'Prediction accuracy: {1-mispredict_count/branch_count}')
    color_log(dut, f'Benchmark clock count: {end_cycle-start_cycle}')

    import tkinter, tkinter.messagebox; root=tkinter.Tk(); root.withdraw(); root.attributes('-topmost', True); tkinter.messagebox.showinfo('Done', 'Task complete')
