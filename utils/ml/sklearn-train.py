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
import zstandard as zstd

from sklearn.ensemble import RandomForestClassifier
from skl2onnx import to_onnx

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
        from sklearn.svm import SVC
        #objModel = SVC(C=0.5)
        objModel = RandomForestClassifier(verbose=1, n_jobs=int(os.getenv("OMP_NUM_THREADS", 3)), max_samples=0.4, n_estimators=250, min_samples_split=6, **paramModel)
        objModel.fit(mtxFeats, aLabels)

    objOnnx = to_onnx(objModel, mtxFeats[:1])
    with open(fileOutput, "wb") as fpwDisk:
        objZstd = zstd.ZstdCompressor(level=19)
        with objZstd.stream_writer(fpwDisk) as fpw:
            fpw.write(objOnnx.SerializeToString())

if __name__ == '__main__':
    main()
