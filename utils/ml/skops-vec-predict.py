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

# Predict output from an skops-formatted model, feature from stdin
# Usage: skops-predict.py <model>

import sys

import numpy as np
import skops.io
import zstandard as zstd

def getConfidence(probs):
    vSorted = np.sort(probs)[::-1]
    return (vSorted[0]-vSorted[1])/vSorted[0]

def logSafe(src):
    rslt = np.where(src > 0, src, -9999)
    np.log(rslt, out=rslt, where=rslt>0)
    return rslt

def main():
    fnameModel = sys.argv[1]

    with open(fnameModel, 'rb') as fpDisk:
        objZunstd = zstd.ZstdDecompressor()
        with objZunstd.stream_reader(fpDisk) as fp:
            dataModel = fp.read()
            objModel = skops.io.loads(dataModel, trusted=skops.io.get_untrusted_types(data=dataModel))
    print(F"Loaded skops model from {fnameModel}", file=sys.stderr)

    print(F"Accept feature dim: ({objModel.n_features_in_},)", file=sys.stderr)
    try:
        if 'classes_' in objModel:
            print(F"Output classes: {objModel.classes_}", file=sys.stderr)
    except:
        pass

    for line in sys.stdin:
        key, values = line.strip().split('\t', 1)
        if len(key) <= 0 or len(values) <= 0: continue
        mtxFeats = np.array(tuple(float(v) for v in values.strip().split('\t')), dtype=np.float32).reshape(1, -1)
        aProb = objModel.predict_proba(mtxFeats).reshape(-1)
        conf = getConfidence(aProb)
        aOut = tuple((F"{c}:{p:.12f}" for c,p in zip(objModel.classes_, logSafe(aProb))))
        print("{}\t{}\t_conf:{:.12f}".format(key, "\t".join(aOut), conf))


if __name__ == '__main__':
    main()
