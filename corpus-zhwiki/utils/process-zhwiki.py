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

# Post-process zh-wiki data, dealing with some noisy symbols and convert it to zh-tw

import re
import sys

from opencc import OpenCC

def main():
    objTrans = str.maketrans(
            "　“”‟＂＃＄％＆＇（）＊＋－／０１２３４５６７８９＜＝＞＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］︿＿ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～╳．：",
            " \"\"\"\"#$%&'()*+-/0123456789<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~×.:",
            "\ufeff\x97"
            )
    objConv = OpenCC('s2twp.json')

    for line in sys.stdin:
        key, text = line.strip().split('\t', 1)
        text = objConv.convert(text.translate(objTrans))
        print(F'{key}\t{text}')

if __name__ == '__main__':
    main()
