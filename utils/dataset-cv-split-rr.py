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
# Using label as guidance in a round-robin manner
# Stdin: label file
# Arguments: n-train n-dev n-test comb-id
# If n-dev = 0, then dev-comb-id must always be 0

import itertools
import sys

from math import comb

def main():
    nTrain = int(sys.argv[1])
    nDev = int(sys.argv[2])
    nTest = int(sys.argv[3])
    nSetTotal = nTrain + nDev + nTest
    nCombTrain = comb(nSetTotal, nTrain)
    nCombTest = comb(nSetTotal-nTrain, nTest)
    nComb = nCombTrain * nCombTest

    idComb = int(sys.argv[4])
    idxTrain = int(idComb / nCombTest)
    idxTest = idComb % nCombTest

    # List all training set combinations
    aCombTrain = list(itertools.combinations(range(nSetTotal), nTrain))
    setTrain = set(aCombTrain[idxTrain])
    setDevTest = set(range(nSetTotal)) - setTrain
    aCombTest = list(itertools.combinations(setDevTest, nTest))
    setTest = set(aCombTest[idxTest])
    setDev = setDevTest - setTest

    sys.stderr.write('ID={} Train={} Dev={} Test={}\n'.format(idComb, str(setTrain), str(setDev), str(setTest)))

    aOrder = []
    maKeys = {}
    for line in sys.stdin:
        key, label = line.strip().split('\t', 1)
        if label not in maKeys:
            maKeys[label] = []
        maKeys[label].append(key)
        aOrder.append(key)

    mAlloc = {} # Allocation of each key into "train" "dev" "test"
    #idThis = 0
    for label in sorted(maKeys):
        lenLabel = len(maKeys[label])
        for i, key in enumerate(maKeys[label]):
            idThis = int(i * (nSetTotal / lenLabel))
            if idThis in setTrain:
                mAlloc[key] = 'train'
            elif idThis in setTest:
                mAlloc[key] = 'test'
            else:
                mAlloc[key] = 'dev'

    for key in aOrder:
        print(F'{key}\t{mAlloc[key]}')

if __name__ == '__main__':
    main()
