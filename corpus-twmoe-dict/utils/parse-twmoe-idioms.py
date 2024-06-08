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

# Parse twmoe idioms dictionary, supposedly from https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/respub/dict_idiomsdict_download.html

import sys
import unicodedata

import xlrd

def main():
    objSheet = xlrd.open_workbook(sys.argv[1]).sheet_by_index(0)
    for i in range(1, objSheet.nrows):
        w = objSheet.cell_value(rowx=i, colx=1)
        if not w or len(w) < 2: continue
        w = "".join(c for c in w if not unicodedata.category(c).startswith("P"))

        # Post-processing some weird words
        if len(w) == 7:
            if w == '醉翁之意不在酒' or w.endswith("又折兵"):
                print(w[:4])
        elif len(w) == 8:
            print(w[:4])
            print(w[4:])

        print(w)

if __name__ == '__main__':
    main()
