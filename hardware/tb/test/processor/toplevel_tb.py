import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from tqdm import tqdm

from utils.cocotb_logging import color_log

@cocotb.test()
async def test_toplevel_branch_predict(dut):
    """ Measures branch prediction performance """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.OSCInst0.CLKHF, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    branch_count = mispredict_count = 0
    last_branch1_value         = False
    last_mistake_trigger_value = False
    for cycle in tqdm(range(2490000)):
        await RisingEdge(dut.clk_i)

        # Count predictions
        curr_branch1_value = dut.processor.branch_predictor_FSM.branch_mem_sig.value
        curr_mistake_trigger_value = dut.processor.mistake_trigger.value
        if curr_branch1_value != last_branch1_value:
            last_branch1_value = curr_branch1_value
            branch_count += curr_branch1_value
        if curr_mistake_trigger_value != last_mistake_trigger_value:
            last_mistake_trigger_value = curr_mistake_trigger_value
            mispredict_count += curr_mistake_trigger_value

        # Count cycles
        if dut.led_o.value == 0b00000011 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_o.value == 0b00000111:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}', color='r')
            break
    
    color_log(dut, f'Benchmark clock count: {end_cycle-start_cycle}')
    color_log(dut, f'Total branching instructions: {branch_count}')
    color_log(dut, f'Mispredicted branches: {mispredict_count}')
    color_log(dut, f'Prediction accuracy: {1-mispredict_count/branch_count}')

@cocotb.test()
async def test_toplevel_branch_predict_2(dut):
    """ Measures branch prediction performance (counts correct predictions also) """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.OSCInst0.CLKHF, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    branch_count = mispredict_count = correct_count = 0

    # track last values so we can detect rising edges
    last_branch_mem = 0

    for cycle in tqdm(range(2_500_000)):
        await RisingEdge(dut.clk_i)

        # detect branch retiring (MEM-stage)
        curr_branch_mem = int(dut.processor.branch_predictor_FSM.branch_mem_sig.value)
        if curr_branch_mem and not last_branch_mem:
            branch_count += 1

            # sample predicted vs actual
            predicted = int(dut.processor.branch_predictor_FSM.prediction.value)
            actual    = int(dut.processor.actual_branch_decision.value)

            if predicted == actual:
                correct_count += 1
            else:
                mispredict_count += 1

        last_branch_mem = curr_branch_mem

        # find start/end of benchmark via LED patterns
        if dut.led_o.value == 0b00000011 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_o.value == 0b00000111:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}', color='r')
            break

    color_log(dut, f'Benchmark clock count: {end_cycle-start_cycle}')
    color_log(dut, f'Total branches retired: {branch_count}')
    color_log(dut, f'Correct predictions   : {correct_count}')
    color_log(dut, f'Mispredicted branches : {mispredict_count}')
    color_log(dut, f'Prediction accuracy   : {correct_count/branch_count:.4f}')
