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

# Parse THUOCL dictionaries from China: https://github.com/thunlp/THUOCL

import sys
import unicodedata

from opencc import OpenCC

def main():
    objOpenCC = OpenCC('s2twp.json')
    thres = int(sys.argv[1])
    maxchar = int(sys.argv[2])

    for line in sys.stdin:
        w, freq = line.strip().split('\t', 1)
        try:
            freq = int(freq)
        except:
            freq = thres+1
        if len(w) < 2 or len(w) > maxchar: continue
        if freq < thres: break
        w = objOpenCC.convert(w)

        # Blacklist
        #if w == '': continue

        print(F'{w}')

if __name__ == '__main__':
    main()
