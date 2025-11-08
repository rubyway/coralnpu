# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import cocotb
import os
import glob
import numpy as np

try:
    # Prefer Bazel's runfiles helper if available.
    from bazel_tools.tools.python.runfiles import runfiles  # type: ignore
except Exception:  # pragma: no cover
    runfiles = None  # Fallback: we'll rely on direct path probing.
from coralnpu_test_utils.core_mini_axi_interface import CoreMiniAxiInterface

@cocotb.test()
async def core_mini_axi_tutorial(dut):
    """Testbench to run your CoralNPU program."""
    # Test bench setup
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())


    # TODO: Load your program into ITCM with "load_elf"
    # Preferred: use Bazel runfiles label; allow override via env; fallback to common Bazel output locations.
    def _resolve_elf_path():
        # 1) Environment override
        for key in ("CORALNPU_ELF", "ELF_PATH"):
            p = os.environ.get(key)
            if p and os.path.isfile(p):
                return p

        # 2) Bazel runfiles lookup
        try:
            if runfiles is not None:
                r = runfiles.Create()
                ws = os.environ.get("TEST_WORKSPACE") or os.environ.get("BUILD_WORKSPACE_DIRECTORY", "coralnpu_hw")
                # TEST_WORKSPACE gives workspace name (e.g. coralnpu_hw). Avoid hardcoding.
                candidates = [
                    f"{ws}/tests/cocotb/tutorial/coralnpu_v2_program.elf",
                    # Historical workspace name fallback
                    "coralnpu/tests/cocotb/tutorial/coralnpu_v2_program.elf",
                ]
                for label in candidates:
                    p = r.Rlocation(label)
                    if p and os.path.isfile(p):
                        return p
        except Exception:
            pass

        # 3) Bazel-bin symlink (present in workspace root when building locally)
        cand = os.path.join("bazel-bin", "tests", "cocotb", "tutorial", "coralnpu_v2_program.elf")
        if os.path.isfile(cand):
            return cand

        # 4) Bazel-out pattern (config/hash segment varies)
        globs = glob.glob(os.path.join("bazel-out", "*", "bin", "tests", "cocotb", "tutorial", "coralnpu_v2_program.elf"))
        for p in globs:
            if os.path.isfile(p):
                return p

        raise FileNotFoundError(
            "Cannot locate coralnpu_v2_program.elf. Build it and/or set CORALNPU_ELF=/path/to/elf."
        )

    elf_path = _resolve_elf_path()
    # Load program and resolve symbols while ELF is open
    with open(elf_path, "rb") as f:
        entry_point = await core_mini_axi.load_elf(f)
        # Attempt to resolve required symbols with fallback candidates.
        def _first_symbol(symbol_lists):
            for names in symbol_lists:
                for name in names:
                    addr = core_mini_axi.lookup_symbol(f, name)
                    if addr is not None:
                        return name, addr
            return None, None

        input1_name, inputs1_addr = _first_symbol([
            ["input1_buffer", "input1", "in1", "input_buffer_1", "in_buf1", "src1", "a_input"],
        ])
        input2_name, inputs2_addr = _first_symbol([
            ["input2_buffer", "input2", "in2", "input_buffer_2", "in_buf2", "src2", "b_input"],
        ])
        output_name, outputs_addr = _first_symbol([
            ["output_buffer", "output", "out", "result_buffer", "outputs_buffer", "out_buf", "result", "res_buffer"],
        ])

        missing = []
        if inputs1_addr is None:
            missing.append("input1_buffer (tried: input1_buffer,input1,in1,input_buffer_1,in_buf1,src1,a_input)")
        if inputs2_addr is None:
            missing.append("input2_buffer (tried: input2_buffer,input2,in2,input_buffer_2,in_buf2,src2,b_input)")
        if outputs_addr is None:
            missing.append("output_buffer (tried: output_buffer,output,out,result_buffer,outputs_buffer,out_buf,result,res_buffer)")
        if missing:
            raise RuntimeError(
                "Missing required ELF symbols: " + ", ".join(missing) +
                "\nPlease ensure your program defines these global symbols (e.g. uint32_t input1_buffer[...];)."
            )

    input1_data = np.arange(8, dtype=np.uint32)
    input2_data = 8994 * np.ones(8, dtype=np.uint32)

    # Write inputs using AXI write helper. Ensure symbols exist.
    # Report resolved names for clarity.
    print(f"Resolved symbols: input1='{input1_name}' @0x{inputs1_addr:08x}, input2='{input2_name}' @0x{inputs2_addr:08x}, output='{output_name}' @0x{outputs_addr:08x}")
    await core_mini_axi.write(inputs1_addr, input1_data)
    await core_mini_axi.write(inputs2_addr, input2_data)

    # TODO: Run your program and wait for halted
    await core_mini_axi.execute_from(entry_point)
    await core_mini_axi.wait_for_halted()

    # TODO: Read your program outputs and print the result
    if outputs_addr is None:
        raise RuntimeError("ELF is missing required symbol 'output_buffer'.")
    rdata = (await core_mini_axi.read(outputs_addr, 4 * 8)).view(np.uint32)
    print(f"RES: {rdata}")