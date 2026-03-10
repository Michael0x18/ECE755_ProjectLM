import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Timer

@cocotb.test()
async def test_1(dut):
    # Set the clock period to 10 ps (100 GHz)
    clock = Clock(dut.clk, 2, unit="ps")
    cocotb.start_soon(clock.start())

    dut.load.value = 0;
    dut.load_clk.value = 0;
    dut.rst_n.value = 0;
    dut.ack_pulse.value = 0;
    
    await ClockCycles(dut.clk, 2)
    
    dut.rst_n.value = 1;
    
    await ClockCycles(dut.clk, 2)
    
    dut.load.value = 1;
    load_clk = Clock(dut.load_clk, 2, unit="ps")
    cocotb.start_soon(load_clk.start())
    
    await ClockCycles(dut.clk, 6)
    
    dut.load.value = 0;
    load_clk.stop()
    dut.load_clk.value = 0;
    
    await ClockCycles(dut.clk, 10)
    
    ack_pulse = Clock(dut.ack_pulse, 27, unit='ps', period_high=5)
    cocotb.start_soon(ack_pulse.start())
  
    await ClockCycles(dut.ack_pulse, 40)