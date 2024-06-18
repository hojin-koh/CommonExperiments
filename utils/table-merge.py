#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2020-2024, Hojin Koh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Merge tables given in sys.stdin
# If --set is specified, repeating values will be eliminated

import fileinput
import sys

def main():
    modeSet = False
    if sys.argv[1] == '--set':
        modeSet = True
        sys.argv.pop(1)
    aOrder = []
    mTable = {}

    for line in sys.stdin:
        try:
            key, value = line.strip().split('\t', 1)
        except:
            value = None
            key = line.strip()
        if len(key) <= 0: continue

        if key not in mTable:
            aOrder.append(key)
            mTable[key] = []
        if value:
            if modeSet and value in mTable[key]:
                continue
            mTable[key].append(value)

    for k in aOrder:
        if len(mTable[k]) > 0:
            print("{}\t{}".format(k, " ".join(mTable[k])))
        else:
            print(F"{k}")

if __name__ == '__main__':
    main()
