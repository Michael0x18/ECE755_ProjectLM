# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_1(dut):


    for i in range(4):

        getattr(dut, "in").value = i  # Can not use "dut.in.value" bc "in" is keyword
        
        await Timer(1, units="ps")   # let combinational logic settle

        expected = 1 << i

        assert dut.out.value == expected, \
            f"For in={i:02b} expected out={expected:04b} but received out={dut.out.value}"




