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
# Perform text normalization on text part of (id)\t(text) records (if sys.argv[2]=="text")
# or key part of (key)\t(number) records from stdin (if sys.argv[2]=="key")
# Also will do unicodedata.normalize()

import fileinput
import re
import sys
import unicodedata

def normalize(objTrans, text):
    # Only normalize the "letter" parts, not punctuations
    return "".join(list(map(
        lambda c: unicodedata.normalize('NFKC', c).translate(objTrans)
        if unicodedata.category(c)[0] == 'L' else c,
        text
        )))

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

    if sys.argv[2] == "text":
        for line in sys.stdin:
            eid, text = line.strip().split('\t', 1)
            text = normalize(objTrans, text.strip())

            print('{}\t{}'.format(eid, text))

    elif sys.argv[2] == "key":
        for line in sys.stdin:
            try:
                key, value = line.strip().split('\t', 1)
            except:
                value = None
                key = line.strip()

            key = normalize(objTrans, key)

            if value:
                print(F"{key}\t{value}")
            else:
                print(F"{key}")

if __name__ == '__main__':
    main()
