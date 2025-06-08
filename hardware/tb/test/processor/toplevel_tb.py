import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from tqdm import tqdm

from utils.cocotb_logging import color_log

# @cocotb.test()
async def test_alu(dut):
    """ Tests ALU via minimal '3+2' C programs """

    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.clk_s, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    for cycle in range(5000):
        await RisingEdge(dut.clk_s)
        # Count cycles
        if dut.led_o.value == 0b00000010 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_o.value == 0b00000001:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}')
            break
    
    count = 0
    for word in dut.data_mem_inst.data_block.value:
        if word != 0:
            color_log(dut, f'{hex(count)} {hex(word)}')
        count += 1
    color_log(dut, f'Output a = {hex(dut.data_mem_inst.data_block.value[0x64//4])}')
    color_log(dut, f'Expted a = {1}')
    color_log(dut, f'Output b = {hex(dut.data_mem_inst.data_block.value[0x68//4])}')
    color_log(dut, f'Expted b = {1}')
    color_log(dut, f'Output c = {hex(dut.data_mem_inst.data_block.value[0x6c//4])}')
    color_log(dut, f'Expted c = {1}')



def arithmetic():
    """ Calculates result of standard arithmetic in arith.c """
    a = b = c = 42
    seed = 0x5876
    for i in range(200):
        a = a + 5
        b = a - i
        c = b << 3
        a = b & c
        c = a | b
        a = b >> 2
        b = ~a
        c = a ^ i
        if a >= 2:
            b = a < 2
        elif b > -5:
            c = a < 2
        if b == 5:
            b -= 1
        elif b == 6:
            c -= 1
        a = i

        bit15 = (seed >> 15) & 1
        bit13 = (seed >> 13) & 1
        bit12 = (seed >> 12) & 1
        bit10 = (seed >> 10) & 1
        new_bit = bit15 ^ bit13 ^ bit12 ^ bit10
        seed = (seed >> 1) | (new_bit << 15)
        a = seed
    # return hex(a), hex(b), hex(c)
    return '0x9eeb', '0x1e63fb1e', '0xf67'

@cocotb.test()
async def test_ck_cycles(dut):
    """ Measures clock cycles elapsed """

    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.clk_s, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    color_log(dut, f'Expted start cycle = 58')
    start_cycle = 0
    for cycle in tqdm(range(300000)):
        await RisingEdge(dut.clk_s)
        # Count cycles
        if dut.led_o.value == 0b00000010 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_o.value == 0b00000001:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}')
            break
    
    count = 0
    expted = arithmetic()
    for word in dut.data_mem_inst.data_block.value:
        if word != 0:
            color_log(dut, f'{hex(count)} {hex(word)}')
        count += 1
    color_log(dut, f'Benchmark clock count: {end_cycle-start_cycle}')
    color_log(dut, f'Output a = {hex(dut.data_mem_inst.data_block.value[0x64//4])}')
    color_log(dut, f'Expted a = {expted[0]}')
    color_log(dut, f'Output b = {hex(dut.data_mem_inst.data_block.value[0x68//4])}')
    color_log(dut, f'Expted b = {expted[1]}')
    color_log(dut, f'Output c = {hex(dut.data_mem_inst.data_block.value[0x6c//4])}')
    color_log(dut, f'Expted c = {expted[2]}')

    import tkinter, tkinter.messagebox; root=tkinter.Tk(); root.withdraw(); root.attributes('-topmost', True); tkinter.messagebox.showinfo('Done', 'Task complete')



# @cocotb.test()
async def test_dhry(dut):
    """ Prints non-zero words in instruction mem """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.clk_s, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    for cycle in tqdm(range(30)):
        await RisingEdge(dut.clk_s)

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
    clock = Clock(dut.clk_s, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    for cycle in range(5):
        await RisingEdge(dut.clk_s)

        count = 0
        for word in dut.inst_mem.instruction_memory.value:
            if word != 0:
                color_log(dut, hex(word))

        # Count cycles
        if dut.led_o.value == 0b00000010 and start_cycle == 0:
            start_cycle = cycle
            color_log(dut, f'start cycle = {start_cycle}')
        elif dut.led_o.value == 0b00000001:
            end_cycle = cycle
            color_log(dut, f'end_cycle = {end_cycle}', color='r')
            break

# @cocotb.test()
async def test_branch_predict(dut):
    """ Measures branch prediction performance """
    ck_freq = 48e6
    ck_period_ns = int(round(1e9/ck_freq))

    # Start the clock
    clock = Clock(dut.clk_s, ck_period_ns, units='ns')
    cocotb.start_soon(clock.start())

    start_cycle = 0
    branch_count = mispredict_count = 0
    # Rising edge detection variables
    branch = last_branch = 0
    prediction = last_prediction = 0
    actual = last_actual = 0
    is_predicted = False
    for cycle in tqdm(range(1279000)):
        await RisingEdge(dut.clk_s)

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
