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

# Find vocabulary list according to training data
# Separated by class

import fileinput
import sys

from collections import Counter

def main():
    modeUniq = False
    if sys.argv[1] == '--uniq':
        modeUniq = True
        sys.argv.pop(1)
    fileClass = sys.argv[1]
    maxWord = int(sys.argv[2])

    aClass = [] # For ordering
    mDocClass = {}
    for line in fileinput.input(fileClass):
        if len(line.strip()) <= 0: continue
        key, label = line.strip().split('\t', 1)
        if len(key) <= 0 or len(label) <= 0: continue
        mDocClass[key] = label
        if label not in aClass:
            aClass.append(label)

    mClassWord = {}
    for line in sys.stdin:
        try:
            key, text = line.strip().split('\t', 1)
        except:
            text = ""
            key = line.strip()
        if len(key) <= 0: continue

        label = mDocClass[key]
        if label not in mClassWord:
            mClassWord[label] = {}

        for w in text.strip().split():
            if w not in mClassWord[label]:
                mClassWord[label][w] = 0
            mClassWord[label][w] += 1

    if modeUniq:
        mClassWordNew = {}
        for l1 in mClassWord:
            setThis = set(mClassWord[l1])
            for l2 in mClassWord:
                if l1 == l2: continue
                setThis -= set(mClassWord[l2])

            mClassWordNew[l1] = {k: mClassWord[l1][k] for k in setThis}

        del mClassWord
        mClassWord = mClassWordNew

    if maxWord > 0:
        for l1 in mClassWord:
            mClassWord[l1] = dict(Counter(mClassWord[l1]).most_common(maxWord))


    print("Extracted words: {}".format(" ".join(str(len(mClassWord[l])) for l in aClass)), file=sys.stderr)
    for label in aClass:
        print("{}\t{}".format(label, " ".join(mClassWord[label])))

if __name__ == '__main__':
    main()
