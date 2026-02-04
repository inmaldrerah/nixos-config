#!/usr/bin/env xonsh
# -*- coding: utf-8 -*-

import json
import sys

outputs = json.loads($(niri msg --json outputs)).keys()

if sys.argv[1] == "idle":
    if p"$HOME/.caffine".is_file():
        ![swaylock -f -c 000000]
        for output in outputs:
            ![niri msg output @(output) off]
elif sys.argv[1] == "resume":
    for output in outputs:
        ![niri msg output @(output) on]
