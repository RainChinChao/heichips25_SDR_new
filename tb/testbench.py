# SPDX-FileCopyrightText: © 2025 XXX Authors
# SPDX-License-Identifier: Apache-2.0

import os
import sys
from pathlib import Path
import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import Timer, ClockCycles


async def apply_sdr_inputs(I1, Q1, I2, Q2, dut):
    """Apply the test stimuli to the sdr module."""
    dut.ui_in.value = Q1 << 4 | I1
    dut.uio_in.value = I2 << 4 | Q2
    await ClockCycles(dut.clk, 1)


async def sdr_test(dut):
    """Execute the test for the sdr module."""
    await apply_sdr_inputs(0, 2, 0, 2, dut)
    await Timer(10, "ns")
    await apply_sdr_inputs(0, 2, 0, 2, dut)
    await Timer(10, "ns")
    await apply_sdr_inputs(0, 2, 0, 2, dut)
    await Timer(10, "ns")
    await apply_sdr_inputs(0, 2, 0, 2, dut)
    await Timer(80, "ns")
    await apply_sdr_inputs(0, 2, 0, 2, dut)
    await Timer(10, "ns")
    await apply_sdr_inputs(0, 0, 0, 0, dut)

    # Wait for the outputs to settle
    await Timer(100, "ns")


@cocotb.test()
async def execute_sdr_test(dut):
    """Execute the sdr test."""

    # Create a clock with a period of 10ns = 100MHz
    clock = Clock(dut.clk, 10, "ns")
    await cocotb.start(clock.start())

    dut.ena.value = 1  # always 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Reset pulse
    dut.rst_n.value = 0
    await Timer(10, "ns")
    dut.rst_n.value = 1

    await sdr_test(dut)


if __name__ == "__main__":
    sim = os.getenv("SIM", "icarus")
    pdk_root = os.getenv("PDK_ROOT", "~/.ciel")
    pdk = os.getenv("PDK", "ihp-sg13g2")
    scl = os.getenv("SCL", "sg13g2_stdcell")
    gl = os.getenv("GL", False)

    testbench_path = Path(__file__).resolve().parent
    sources = []  # [testbench_path / 'testbench.sv']
    defines = {}

    MACRO_NL = testbench_path / "../macro/nl/heichips25_template.nl.v"

    if gl:
        if not MACRO_NL.exists():
            print(
                f"The macro netlist {MACRO_NL} does not exist. Did you implement the macro?"
            )
            sys.exit(0)

        sources.append(
            Path(pdk_root).expanduser()
            / pdk
            / "libs.ref"
            / scl
            / "verilog"
            / f"{scl}.v"
        )
        sources.append(MACRO_NL)
        defines = {"FUNCTIONAL": True, "UNIT_DELAY": "#0"}
    else:
        sources.extend(list(testbench_path.glob("../src/*")))
        defines = {"RTL": True}

    hdl_toplevel = "heichips25_template"

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=hdl_toplevel,
        defines=defines,
        timescale=["1ns", "1ps"],
        waves=True,
        build_args=["--trace", "--trace-fst", "--trace-structs"]
        if sim == "verilator"
        else ["-gno-specify"],
    )

    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module="testbench,",
        timescale=["1ns", "1ps"],
        waves=True,
        plusargs=["--trace-file", f"{hdl_toplevel}.fst"] if sim == "verilator" else [],
    )
