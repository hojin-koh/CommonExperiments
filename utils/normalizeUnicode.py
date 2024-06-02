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

# Based on a table of (bad character)\t(good character) records as argv[1],
# Perform text normalization on the text part of (id)\t(text) records from stdin
# Also will do unicodedata.normalize()

import fileinput
import re
import sys
import unicodedata

def main():
    mTrans = {}
    if len(sys.argv)>1:
        # Read the conversion table
        for line in fileinput.input(sys.argv[1]):
            c1, c2 = line.strip().split('\t', 1)
            if len(c1) == 0 or len(c2) == 0:
                continue
            mTrans[c1] = c2
    objTrans = str.maketrans(mTrans)

    for line in sys.stdin:
        eid, text = line.split('\t', 1)
        text = text.strip()

        # Only normalize the "letter" parts, not punctuations
        text2 = "".join(list(map(
            lambda c: unicodedata.normalize('NFKC', c) if unicodedata.category(c)[0] == 'L' else c,
            text
            )))
        for i, c in enumerate(text):
            if text[i] != text2[i]:
                sys.stderr.write(F"REPLACE {text[i]} -> {text2[i]}\n")
        print('{}\t{}'.format(eid, text2.translate(objTrans)))

if __name__ == '__main__':
    main()
