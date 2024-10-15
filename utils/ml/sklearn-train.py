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

# Train a sklearn model with training features on stdin
# Usage: sklearn-train.py <modeltype> <json-params> <model-output> <label-file>

import fileinput
import os
import sys
import json

import numpy as np
import skops.io
import zstandard as zstd

from sklearn.ensemble import ExtraTreesClassifier
from sklearn.neural_network import MLPClassifier

np.random.seed(0x19890604)

def main():
    typeModel = sys.argv[1]
    paramModel = json.loads(sys.argv[2])
    fileOutput = sys.argv[3]
    fileLabel = sys.argv[4]

    mLabel = {}

    for line in fileinput.input(fileLabel):
        key, label = line.strip().split('\t', 1)
        mLabel[key] = label

    aFeats = []
    aLabels = []
    for line in sys.stdin:
        key, values = line.strip().split('\t', 1)
        if len(key) <= 0 or len(values) <= 0: continue
        aFeats.append(np.array(tuple(float(v) for v in values.strip().split('\t')), dtype=np.float32))
        aLabels.append(mLabel[key])
    mtxFeats = np.vstack(aFeats)
    print(F"Training features: {mtxFeats.shape}", file=sys.stderr)
    print(F"Training labels: {len(aLabels)}", file=sys.stderr)

    if typeModel == "rf":
        objModel = ExtraTreesClassifier(n_jobs=int(os.getenv("OMP_NUM_THREADS", 3)), bootstrap=True, oob_score=True, n_estimators=768, **paramModel)
        objModel.fit(mtxFeats, aLabels)
    elif typeModel == "mlp":
        objModel = MLPClassifier(hidden_layer_sizes=(200, 150, 200, 50), **paramModel)
        objModel.fit(mtxFeats, aLabels)

    print(F"Training accuracy: {objModel.score(mtxFeats, aLabels)*100}%", file=sys.stderr)

    with open(fileOutput, "wb") as fpwDisk:
        objZstd = zstd.ZstdCompressor(level=19, threads=int(os.getenv("OMP_NUM_THREADS", 3)))
        with objZstd.stream_writer(fpwDisk) as fpw:
            fpw.write(skops.io.dumps(objModel))

if __name__ == '__main__':
    main()
