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

# Parse a word frequency list into dictionary, supposedly from https://github.com/bedlate/cn-corpus

import re
import sys
import unicodedata

import xlrd
from opencc import OpenCC

def main():
    objOpenCC = OpenCC('s2twp.json')
    objSheet = xlrd.open_workbook(sys.argv[1]).sheet_by_index(0)

    for i in range(7, objSheet.nrows):
        w = objSheet.cell_value(rowx=i, colx=1)
        if not w or len(w) < 2 or len(w) > 4: continue

        freqCumulative = float(objSheet.cell_value(rowx=i, colx=4))
        if freqCumulative >= 90: break

        w = objOpenCC.convert(w)

        # Blacklist
        if re.search(R"[一二三四五六七八九十零中黨了呢嗎嘛們人的]|戰爭", w): continue
        if any(w.startswith(c) for c in ("最","很","較","不")): continue
        if len(w) == 3 and any(w.endswith(c) for c in ("市", "縣", "省")): continue

        w = "".join(c for c in w if not unicodedata.category(c).startswith("P"))
        print(w)

if __name__ == '__main__':
    main()
