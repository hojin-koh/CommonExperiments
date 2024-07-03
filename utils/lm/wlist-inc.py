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

# Calculate the inclusion rate of text in regard to a class-wise word-list

import fileinput
import sys

def main():
    modeOOV = False
    modeCount = False
    modeUniq = False
    while True:
        if sys.argv[1] == '--uniq':
            modeUniq = True
            sys.argv.pop(1)
        elif sys.argv[1] == '--count':
            modeCount = True
            sys.argv.pop(1)
        elif sys.argv[1] == '--oov':
            modeOOV = True
            sys.argv.pop(1)
        else:
            break
    fileWlist = sys.argv[1]

    aClass = [] # For ordering
    mClassWords = {}
    for line in fileinput.input(fileWlist):
        if len(line.strip()) <= 0: continue
        label, wlist = line.strip().split('\t', 1)
        if len(label) <= 0 or len(wlist) <= 0: continue
        if label not in mClassWords:
            aClass.append(label)
            mClassWords[label] = set(wlist.strip().split())

    for line in sys.stdin:
        if len(line.strip()) <= 0: continue
        key, text = line.strip().split('\t', 1)

        aWords = text.strip().split()
        setEncountered = set()
        aCountInclude = [0 for _ in aClass]
        for w in aWords:
            if modeUniq and w in setEncountered: continue
            for i, label in enumerate(aClass):
                if w in mClassWords[label]:
                    aCountInclude[i] += 1
            setEncountered.add(w)

        if modeUniq:
            nTotal = len(setEncountered)
        else:
            nTotal = len(aWords)

        if modeOOV:
            aCountInclude = [nTotal-c for c in aCountInclude]

        if not modeCount:
            aCountInclude = [c/nTotal for c in aCountInclude]

        print("{}\t{}".format(key, "\t".join(str(c) for c in aCountInclude)))


if __name__ == '__main__':
    main()
