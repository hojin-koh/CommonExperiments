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

import re
import sys
import unicodedata

from opencc import OpenCC

def main():
    objOpenCC = OpenCC('s2twp.json')
    conv = int(sys.argv[1]) # 1=Convert, 0=noconvert
    thres = int(sys.argv[2])
    maxchar = int(sys.argv[3])

    for line in sys.stdin:
        aRslt = line.strip().split(maxsplit=1)
        if len(aRslt) == 0: continue

        w = aRslt[0]
        try:
            freq = int(aRslt[1])
        except:
            freq = thres+1

        if len(w) < 2 or len(w) > maxchar: continue
        if freq < thres: continue
        if conv == 1:
            w = objOpenCC.convert(w)

        # Blacklist
        if re.search(R"[一二三四五六七八九十零了呢嗎嘛們人的]", w): continue
        if len(w) >= 3 and any(w.endswith(c) for c in ("市", "縣", "省", "區", "鄉", "鎮")): continue

        print(w)

if __name__ == '__main__':
    main()
