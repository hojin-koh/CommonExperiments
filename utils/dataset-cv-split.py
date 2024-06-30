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

# Output the nth dataset split file for cross-validation
# Using label as guidance in a block manner
# Stdin: label file
# Arguments: n-train n-dev n-test comb-id
# If n-dev = 0, then there will be no development set

import itertools
import sys

from math import comb

def main():
    nTrain = int(sys.argv[1])
    nTest = int(sys.argv[2])
    nSetTotal = nTrain + nTest
    nComb = comb(nSetTotal, nTrain)

    idx = int(sys.argv[3])

    # List all training set combinations
    aComb = list(itertools.combinations(range(nSetTotal), nTrain))
    setTrain = set(aComb[idx])
    setTest = set(range(nSetTotal)) - setTrain

    sys.stderr.write('ID={} Train={} Test={}\n'.format(idx, str(setTrain), str(setTest)))

    # spec in format name=frac:name=frac, like train=7:dev1=2:dev2=1
    if len(sys.argv) >= 5:
        aSubTrainSpec = sys.argv[4].strip().split(":")
    else:
        aSubTrainSpec = ("train1=1",)
    aSubTrain = []
    nSubTrainTotal = 0
    for spec in aSubTrainSpec:
        label, frac = spec.strip().split("=", 2)
        frac = int(frac)
        nSubTrainTotal += frac
        aSubTrain.append((label, frac))

    mSubTrain = {}
    idSubTrainCounter = 0
    for spec in aSubTrain:
        for i in range(spec[1]):
            mSubTrain[idSubTrainCounter] = spec[0]
            idSubTrainCounter += 1

    aOrder = []
    maKeys = {}
    for line in sys.stdin:
        key, label = line.strip().split('\t', 1)
        if label not in maKeys:
            maKeys[label] = []
        maKeys[label].append(key)
        aOrder.append(key)

    mAlloc = {} # Allocation of each key into "train" "test"
    for label in sorted(maKeys):
        lenLabel = len(maKeys[label])
        lenTrain = lenLabel * len(setTrain) / nSetTotal
        idxTrain = 0
        for i, key in enumerate(maKeys[label]):
            idThis = int(i * (nSetTotal / lenLabel))
            if idThis in setTest:
                mAlloc[key] = 'test'
                continue
            # If it is training set or some subset of it
            idSubThis = int(idxTrain * (nSubTrainTotal / lenTrain))
            idxTrain += 1
            mAlloc[key] = 'train:{}'.format(mSubTrain[idSubThis])

    for key in aOrder:
        print(F'{key}\t{mAlloc[key]}')

if __name__ == '__main__':
    main()
