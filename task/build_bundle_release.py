# -*- coding: utf-8 -*-
#!/usr/bin/env python3

import os
import subprocess

import lib.tool_kit as tk


# 请在根路径下执行
def main():
    current_path = os.getcwd()

    ouput_filepath = os.path.join(
        current_path, "build/app/outputs/bundle/release/app-release.aab")
    tk.delete_file_if_exists(ouput_filepath)

    symboldir = os.path.join(current_path, "build/app/outputs/symbols")

    build_num = tk.cp_timestamp()
    cmd = "git pull"
    cmd = cmd + "&& fvm flutter pub get"
    cmd = cmd + f" && fvm flutter build appbundle --split-debug-info={symboldir} --obfuscate"
    print(f"cmd: {cmd}")
    subprocess.call(cmd, shell=True)

    print(f"output file done: {ouput_filepath}\n symbols: {symboldir}")


if __name__ == "__main__":
    main()
