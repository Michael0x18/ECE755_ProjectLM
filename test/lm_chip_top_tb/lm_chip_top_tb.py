# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random
import itertools
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.regression import TestFactory  

# GLOBALs
WIDTH = 16
_initialization = True
_rx_state = 0  # Needs to be shared between async busses


async def send_data(dut, data):
    
    dut.MOSI.value = 1
    
    for i in range(WIDTH):
        await FallingEdge(dut.SCLK)
        dut.MOSI.value = (data >> i) & 0x1
    
    await FallingEdge(dut.SCLK)
    
    dut.MOSI.value = 0
    
async def recieve_data(dut):

    val_arr = []
    
    for i in range(WIDTH):
        await FallingEdge(dut.SCLK)
        val_arr.append(int(dut.MISO.value))
    
    val_arr.reverse()
    
    val = 0
    
    for b in val_arr:
        val = (val << 1) | b
        
    await RisingEdge(dut.SCLK)
    return val


async def pulse(clk, signal):
    await RisingEdge(clk)
    signal.value = 1
    await RisingEdge(clk)
    signal.value = 0


async def loopback_tx(dut, delays_ns=[5,5,5,5]):
    DATA_LINES = 4
    while True:
        await dut.TX.value_change   # Wait for ANY change

        val = dut.TX.value
        # Launch delayed update (don’t block loop)
        for i in range(DATA_LINES):                                                                                                                                                                                                                                                                        
              bit = (int(dut.TX.value) >> i) & 1
              cocotb.start_soon(delayed_tx_line(dut, i, bit, delays_ns[i]))   
        
        await Timer(0.1, unit="ns") # Brief wait so non-blocking


async def delayed_tx_line(dut, bit_idx, val, delay_ns):                                                                                                                                                                                                                                           
    global _rx_state                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                             
    await Timer(delay_ns, units="ns")     

    if val:
        # Set bit                                                                                                                                                                                                                                                                                       
        _rx_state |= (1 << bit_idx)                                                                                                                                                                                                                                                             
    else:     
        # Clear bit                          
        _rx_state &= ~(1 << bit_idx)
    dut.RX.value = _rx_state  


async def loopback_ack(dut, delay_ns=5):
    while True:
        await dut.RX_ACK.value_change

        val = dut.RX_ACK.value
        # Launch delayed update (don’t block loop)
        cocotb.start_soon(delayed_ack(dut, val, delay_ns))

        await Timer(0.1, unit="ns") # Brief wait so non-blocking


async def delayed_ack(dut, val, delay_ns):
    await Timer(delay_ns, unit="ns")
    dut.TX_ACK.value = val


async def reset_n(dut):
    dut.rst_n.value = 0


async def run_test(dut, data, clk_ns, sclk_ns, tx_delays_ns, ack_delay_ns):
    cocotb.log.info("Sending 0x%04X | clk=%sns sclk=%sns tx_delays=%sns ack_delay=%sns",
                    data, clk_ns, sclk_ns, tx_delays_ns, ack_delay_ns)

    # Start a 1GHz driving sync clock. This is still stupidly fast compared to what we're actually going to use
    clock = Clock(dut.clk, clk_ns,  unit="ns")
    cocotb.start_soon(clock.start())

    # Start loopbacks
    cocotb.start_soon(loopback_tx(dut, tx_delays_ns))
    cocotb.start_soon(loopback_ack(dut, ack_delay_ns))


    dut.MOSI.value = 0
    dut.SCLK.value = 0
    dut.CAPTURE.value = 0

    dut.RDY.value = 0
    dut.LOAD.value = 0

    await ClockCycles(dut.clk, 2)
    
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 2)
    
    
    sclk = Clock(dut.SCLK, sclk_ns, unit='ns')
    cocotb.start_soon(sclk.start())
    
    # 1. Send data over SPI
    await send_data(dut, data)

    # 2. Pulse LOAD
    await pulse(dut.clk, dut.LOAD)

    # 3. Wait for RX to assert VLD
    await RisingEdge(dut.VLD)

    # 4. Pulse CAPTURE
    await pulse(dut.clk, dut.CAPTURE)

    # 5. Pulse RDY
    await pulse(dut.clk, dut.RDY)

    # 6. Wait for TX to assert DONE
    await RisingEdge(dut.DONE)

    # 7. Output recieved data over SPI
    recieved_data = await recieve_data(dut)

    assert recieved_data == data, f"Expected 0x{data:04X}, got 0x{recieved_data:04X}"
    cocotb.log.info("Recieved: 0x%04X", recieved_data)


   
async def loopback_test(dut, data, clk_ns, sclk_ns, tx_delays_ns, ack_delay_ns):
    global _initialization
    if _initialization:
        await reset_n(dut) 
        _initialization = False
    
    await run_test(dut, data, clk_ns, sclk_ns, tx_delays_ns, ack_delay_ns)


################################# TESTS #################################
# DATA = [0xB00F, 0xDEAD, 0x1234]
DATA = [random.randint(0, 0xFFFF) for _ in range(5)]
# CLOCKS = [16, 63, 125, 250, 500, 1000]  # 62.5 MHz to 1 MHz
# DELAYS = [1, 10, 100, 1000]  # 1 ns to 1 us
CLOCKS = [16, 1000]  # 62.5 MHz to 1 MHz
DELAYS = [1, 1000]  # 1 ns to 1 us
LINE_DELAYS = list(set(itertools.product(DELAYS, repeat=4)))

tf = TestFactory(test_function=loopback_test)
tf.add_option("data", DATA) 
tf.add_option("clk_ns", CLOCKS)  # 62.5 MHz to 1 MHz
tf.add_option("sclk_ns", CLOCKS) # 62.5 MHz to 1 MHz
tf.add_option("tx_delays_ns", LINE_DELAYS)
tf.add_option("ack_delay_ns", DELAYS)  
tf.generate_tests()