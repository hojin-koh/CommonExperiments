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

# Parse twmoe variants table, supposedly from https://github.com/kcwu/moedict-variants
# Need two additional files:
#   sys.argv[1] ICU confusable.txt
#   sys.argv[2] character frequency table for tie-breaking

import fileinput
import re
import sys
import unicodedata

from opencc import OpenCC


def main():
    modeOld = False
    if sys.argv[1] == "--old":
        modeOld = True
        sys.argv.pop(1)

    objOpenCC = OpenCC('s2tw.json')

    # Read ICU confusable table
    mConfusable = {}
    for line in fileinput.input(sys.argv[1]):
        line = line.strip()
        # Don't touch Japanese texts
        if line.find("KATAKANA") != -1 or line.find("HIRAGANA") != -1:
            continue

        match = re.search(R'\(\s*(\S)\s*→\s*(\S)\s*\)', line)
        if match:
            c1 = unicodedata.normalize('NFKC', match.group(1))
            c2 = unicodedata.normalize('NFKC', match.group(2))
            if c1 == c2:
                continue

            # Non-letters (symbols, punctuations, etc)
            if unicodedata.category(c2)[0] != 'L':
                continue

            # Not a wide character... likely not what we're interested in
            if unicodedata.east_asian_width(c2) != 'W':
                continue

            mConfusable[c1] = c2

    # Read character frequency table
    mFreq = {}
    for line in fileinput.input(sys.argv[2]):
        c, freq = line.strip().split('\t', 1)
        if len(c) != 1: continue
        mFreq[c] = int(freq)

    # Read the real deal
    mGoodChar = {} # The main good chars table
    mCharId = {} # The reverse table of each good chars
    mVar = {} # Variants
    mVarId = {} # The reverse table of each variant chars
    for line in sys.stdin:
        if modeOld:
            dumb, line = line.split('\t', 1)
            if len(line.strip()) == 0: continue

            match = re.search(R'"row">(附 錄 字|異 體 字|正 字).*<code>([-A-Z0-9]+)</code>.*<big2>(?:<img alt=")?([^"<]+)["<]', line.strip())
            cid = match.group(2)
            if match.group(1) == "正 字":
                tag = '正'
            else:
                tag = '異'

            c = match.group(3)
            # Filter out non-standard custom characters and weird catches
            if len(c) != 1: continue
            if unicodedata.category(c) == 'Co':
                continue
            c = unicodedata.normalize('NFKC', c)
        else:
            cid, tag, dumb, c, dumb = line.split('\t')

            # Filter out non-standard custom characters and weird catches
            if len(c) != 1: continue
            if unicodedata.category(c) == 'Co':
                continue
            c = unicodedata.normalize('NFKC', c)

        if c not in mVarId:
            mVarId[c] = []
        mVar[cid] = c

        if tag == '正':
            # For duplicated chars, create a link
            if c in mCharId:
                mGoodChar[cid] = mGoodChar[mCharId[c]]
                continue
            mGoodChar[cid] = {
                    'variants': [c],
                    'char': c,
                    'freq': mFreq.get(c, 0),
                    }
            mCharId[c] = cid
            mVarId[c].append(cid)

    # Step 10: build missing good chars with lowest-numbered variant
    for cid in sorted(mVar):
        cidGood = cid.split('-')[0]
        c = mVar[cid]
        if c in mCharId: continue
        if cidGood in mGoodChar: continue
        mGoodChar[cidGood] = {
                'variants': [c],
                'char': c,
                'freq': mFreq.get(c, 0),
                }
        mCharId[c] = cidGood

    # Step 20: Put ICU confusable chars into the mix
    numICU = 0
    for c1, c2 in mConfusable.items():
        numICU += 1
        # The "target" char is considered the good char
        if c2 not in mCharId:
            idICU = F'ICU{numICU:05d}'
            mCharId[c2] = idICU
            mGoodChar[idICU] = {
                    'char': c2,
                    'freq': mFreq.get(c2, 0),
                    'variants': [c2],
                    }
        else:
            idICU = mCharId[c2]

        # The "source" char is considered a variant of the "target" char
        if c2 not in mVarId:
            mVarId[c2] = [idICU]
        if c1 not in mVarId:
            mVarId[c1] = []
        idICUVar = F'{idICU}-999'
        mVar[idICUVar] = c1

    # Step 30: file all variants into GoodChars table
    for cid in sorted(mVar):
        cidGood = cid.split('-')[0]
        c = mVar[cid]
        # At this point, if there's still no good chars, ignore it
        if cidGood not in mGoodChar:
            continue

        # If it is already there, ignore it
        if c in mGoodChar[cidGood]['variants']:
            continue

        # If it is also a good char, ignore it
        if c in mCharId:
            continue

        # Add it
        mGoodChar[cidGood]['variants'].append(c)
        mVarId[c].append(cidGood)

    # Step 110: Dedup variants
    for v, aCid in tuple(mVarId.items()):
        if len(aCid) <= 1: continue
        # First, see if said character is a simplified version of another char
        # If there's none, then decide by word frequency
        vTrad = objOpenCC.convert(v)
        cidKeep = max(aCid, key=lambda cid: int(mGoodChar[cid]['char'] == vTrad)*10000000 + mGoodChar[cid]['freq'])
        for cid in aCid:
            if cid == cidKeep: continue
            mGoodChar[cid]['variants'].remove(v)
            mVarId[v].remove(cid)

    # Step 130: delete all good chars that actually has no variants
    for cid in sorted(mGoodChar):
        if len(mGoodChar[cid]['variants']) > 1: continue
        c = mGoodChar[cid]['char']
        if c in mCharId:
            del mCharId[c]
        del mGoodChar[cid]

    # Step 210: Change the good char if it can be converted to traditional chinese which match one of its variants
    # (Will probably break mCharId here)
    for cid, m in mGoodChar.items():
        if len(m['variants']) <= 1: continue
        charOrig = m['char']
        charNew = objOpenCC.convert(charOrig)
        if charOrig != charNew and charNew in m['variants']:
            m['char'] = charNew

    # Finally, print! and skip empty good chars
    for key in sorted(mGoodChar):
        m = mGoodChar[key]
        if len(m['variants']) <= 1: continue
        c2 = m['char']
        for c1 in m['variants']:
            if c1 == c2: continue
            print(F'{c1}\t{c2}')

    # Hard-coded characters
    print(F'臺\t台')
    print(F'萠\t萌')


if __name__ == '__main__':
    main()
