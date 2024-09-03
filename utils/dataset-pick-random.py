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

# Pick random samples without replacement from a table
# With Reservoir sampling
# Optionally can have a label file specified,
# and we'll give each label the same number of samples

import fileinput
import random
import sys

random.seed(0x19890604)

def main():
    nPick = int(sys.argv[1])

    mLabel = {}
    aLabels = []
    # Read the label table
    if len(sys.argv) > 2:
        for line in fileinput.input(sys.argv[2]):
            key, label = line.strip().split('\t', 1)
            if len(key) == 0 or len(label) == 0:
                continue
            if label not in aLabels:
                aLabels.append(label)
            mLabel[key] = label

    if len(aLabels) <= 0:
        aLabels.append('_')
    nPickEach = nPick / len(aLabels)
    nRemainder = nPick % len(aLabels)

    mLabelCapacity = {}
    mLabelCount = {}
    mReservoir = {}
    for l in aLabels:
        mLabelCapacity[l] = nPickEach
        mLabelCount[l] = 0
        mReservoir[l] = []
    mLabelCapacity[aLabels[-1]] += nRemainder

    # Algorithm: https://en.wikipedia.org/wiki/Reservoir_sampling#Simple:_Algorithm_R
    aOrder = [] # Just for preserving key order, things in here are not necessarily picked
    for line in sys.stdin:
        key, value = line.strip().split('\t', 1)
        label = mLabel.get(key, '_')
        mLabelCount[label] += 1
        if len(mReservoir[label]) < mLabelCapacity[label]:
            aOrder.append((key, len(mReservoir[label])))
            mReservoir[label].append((key, value))
            continue
        r = random.randint(1, mLabelCount[label])
        if r <= mLabelCapacity[label]:
            aOrder.append((key, r-1)) # Convert to 0-based index
            mReservoir[label][r-1] = (key, value)

    for (key, idx) in aOrder:
        label = mLabel.get(key, '_')
        #print(key, idx, label, file=sys.stderr)
        if mReservoir[label][idx][0] != key: # If already discarded
            continue
        value = mReservoir[label][idx][1]
        print(F'{key}\t{value}')

if __name__ == '__main__':
    main()
