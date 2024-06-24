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

# Parse dictionaries in "word freq" format

import sys

from opencc import OpenCC

def main():
    thres = int(sys.argv[1])
    maxchar = int(sys.argv[2])
    objConv = None
    if len(sys.argv) > 3 and sys.argv[3].endswith(".json"):
        objConv = OpenCC(sys.argv[3])
        del sys.argv[3]

    for line in sys.stdin:
        aRslt = line.strip().split(maxsplit=1)
        if len(aRslt) == 0: continue

        w = aRslt[0]
        try:
            freq = int(aRslt[1])
        except:
            freq = thres+1

        if len(w) < 1 or len(w) > maxchar: continue
        if freq < thres: continue
        if objConv:
            w = objConv.convert(w)

        print(w)

if __name__ == '__main__':
    main()
