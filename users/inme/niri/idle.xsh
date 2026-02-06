#!/usr/bin/env xonsh
# -*- coding: utf-8 -*-

import sys

if len(sys.argv) == 1:
    self = sys.argv[0]
    ![swayidle -w timeout 300 @(f"{self} idle") resume @(f"{self} resume") before-sleep "swaylock -f -c 000000"]
elif sys.argv[1] == "idle":
    if p"$HOME/.caffine".is_file():
        ![swaylock -f -c 000000]
        ![niri msg output power-off-monitors]
elif sys.argv[1] == "resume":
    ![niri msg action power-on-monitors]
