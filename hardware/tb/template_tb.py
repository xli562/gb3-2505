import numpy as np
from numpy.random import uniform, random, randint, seed
from tqdm import tqdm
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import matplotlib.pyplot as plt

from mods.logging_mods import *
from mods.quantization_mods import *

lst = [0, 0.6, 0.7, 0.8, 0.9]

# for i in lst:
#     print(
        
#     hex(float_to_fixed_point(i, 10, 9))[2:].upper()
        
#     )

print(fixed_point_to_float(0x1cd, 10, 9))