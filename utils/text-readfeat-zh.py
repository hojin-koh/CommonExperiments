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

# Extract several word-based and char-based features for readability

import re
import sys

from strokes import strokes

def main():
    for line in sys.stdin:
        eid, text = line.strip().split('\t', 1)
        aWords = text.strip().split()

        # Populate characters
        aChars = []
        nSpecialToken = 0
        for w in aWords:
            if w.startswith("<"):
                aChars.append(w)
                nSpecialToken += 1
                continue
            for c in w:
                aChars.append(c)

        nWord = len(aWords)
        nChar = len(aChars)
        nuWord = len(set(aWords))
        nuChar = len(set(aChars))
        nNormalWord = nWord - nSpecialToken
        nNormalChar = nChar - nSpecialToken
        ruWord = nuWord / nWord if nWord > 0 else 0
        ruChar = nuChar / nChar if nChar > 0 else 0

        aStrokes = tuple(strokes(c) for c in aChars if not c.startswith("<"))
        avgStroke = sum(aStrokes) / nNormalChar if nNormalChar>0 else 0
        maxStroke = max(aStrokes)
        rStrokeLow = len(tuple(s for s in aStrokes if s <= 10)) / nNormalChar if nNormalChar>0 else 0
        rStrokeMid = len(tuple(s for s in aStrokes if s > 10 and s <= 20)) / nNormalChar if nNormalChar>0 else 0
        rStrokeHigh = len(tuple(s for s in aStrokes if s > 20)) / nNormalChar if nNormalChar>0 else 0

        avgChar = sum(len(w) for w in aWords if not w.startswith("<")) / nNormalWord if nNormalWord>0 else 0
        maxChar = max(len(w) for w in aWords if not w.startswith("<"))
        nWord1c = sum(len(w)==1 for w in aWords if not w.startswith("<")) / nNormalWord if nNormalWord>0 else 0
        nWord2c = sum(len(w)==2 for w in aWords if not w.startswith("<")) / nNormalWord if nNormalWord>0 else 0
        nWord3c = sum(len(w)==3 for w in aWords if not w.startswith("<")) / nNormalWord if nNormalWord>0 else 0
        nWord4c = sum(len(w)>=4 for w in aWords if not w.startswith("<")) / nNormalWord if nNormalWord>0 else 0

        aFeats = [
                nWord, nChar, nuWord, nuChar, ruWord, ruChar,
                avgStroke, maxStroke, rStrokeLow, rStrokeMid, rStrokeHigh,
                avgChar, maxChar, nWord1c, nWord2c, nWord3c, nWord4c
                ]
        feats = "\t".join("{:.8f}".format(v) for v in aFeats)
        
        print('{}\t{}'.format(eid, feats))

if __name__ == '__main__':
    main()
