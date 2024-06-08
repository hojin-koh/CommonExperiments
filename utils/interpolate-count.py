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

# Merge tables given in sys.argv like this: weight1 file1 weight2 file2 ...
# If --normalize is specified before all other arguments, normalize to the sum of 1st file

import fileinput
import sys

from math import ceil

def main():
    modeNormalize = False
    if sys.argv[1] == '--normalize':
        modeNormalize = True
        sys.argv.pop(1)
    hasNumber = True
    isFloat = False
    aaOrder = []
    aCnt = []
    amTable = []
    for w, fname in ((float(sys.argv[i]), sys.argv[i+1]) for i in range(1, len(sys.argv), 2)):
        amTable.append({})
        mTable = amTable[-1]
        aaOrder.append([])
        aOrder = aaOrder[-1]
        cntThis = 0

        for line in fileinput.input(fname):
            if len(line.strip()) <= 0: continue
            try:
                key, num = line.strip().split('\t', 1)
                if num.find('.') != -1:
                    num = float(num.strip())
                    isFloat = True
                else:
                    num = int(num.strip())
            except:
                hasNumber = False
                num = 1
                key = line.strip()

            cntThis += num
            num *= 1.0 * w # Force into float

            if key not in mTable:
                aOrder.append(key)
                mTable[key] = num
            else:
                mTable[key] += num

        aCnt.append(cntThis)

    # Normalize each table, then add to the overall table
    mTable = {}
    aOrder = []
    for i, (cnt, mTableThis) in enumerate(zip(aCnt, amTable)):
        for key in aaOrder[i]:
            if key not in mTable:
                mTable[key] = 0
                aOrder.append(key)
            if modeNormalize:
                mTable[key] += mTableThis[key] / cnt * aCnt[0]
            else:
                mTable[key] += mTableThis[key]

    # Output
    if hasNumber and isFloat:
        for k in aOrder:
            v = mTable[k]
            print(F'{k}\t{v}')
    elif hasNumber and not isFloat:
        for k in aOrder:
            v = mTable[k]
            print(F'{k}\t{ceil(v)}')
    else:
        for k in aOrder:
            print(F'{k}')

if __name__ == '__main__':
    main()
