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

# Predict output from an onnx-formatted model, feature from stdin
# Usage: onnx-predict.py <model>

import sys

import numpy as np
import zstandard as zstd
import onnxruntime as onnx

from sklearn.ensemble import RandomForestClassifier
from skl2onnx import to_onnx

def main():
    modelInput = sys.argv[1]

    with open(modelInput, 'rb') as fpDisk:
        objZunstd = zstd.ZstdDecompressor()
        with objZunstd.stream_reader(fpDisk) as fp:
            objModel = onnx.InferenceSession(fp.read(), providers=["CPUExecutionProvider"])
    nameFeats = objModel.get_inputs()[0].name
    nameLabel = objModel.get_outputs()[0].name
    print(F"Accept feature: {objModel.get_inputs()[0].shape} ({objModel.get_inputs()[0].type})", file=sys.stderr)

    for line in sys.stdin:
        key, values = line.strip().split('\t', 1)
        if len(key) <= 0 or len(values) <= 0: continue
        feats = np.array(tuple(float(v) for v in values.strip().split('\t')), dtype=np.float32).reshape(1, -1)
        rslt = tuple(objModel.run([nameLabel], {nameFeats: feats})[0])[0]
        print(F"{key}\t{rslt}")


if __name__ == '__main__':
    main()
