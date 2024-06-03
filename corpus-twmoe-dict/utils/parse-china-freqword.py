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
        if freqCumulative >= 80: break

        w = objOpenCC.convert(w)
        if re.search(R'[一二三四五六七八九十人你我他上下不無中了呢嗎嘛的是就很最較]|戰爭', w): continue

        w = "".join(c for c in w if not unicodedata.category(c).startswith("P"))
        print(w)

if __name__ == '__main__':
    main()
