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

# Predict class from a BERT-based classifier
# Usage: bertclass-predict.py <model>

import os
import sys
import json

from pathlib import Path

from transformers import pipeline

def main():
    dirModel = sys.argv[1]

    try:
        objPipeline = pipeline('text-classification', model=dirModel, tokenizer=dirModel, device='cuda')
    except:
        objPipeline = pipeline('text-classification', model=dirModel, tokenizer=dirModel)
    print(F"Loaded transformer model from {dirModel}", file=sys.stderr)

    for line in sys.stdin:
        key, text = line.strip().split('\t', 1)
        if len(key) <= 0 or len(text) <= 0: continue
        mRslt = objPipeline(text, top_k=None, padding=True, truncation=True)
        aOut = tuple(("{}:{:.12f}".format(l['label'], l['score']) for l in mRslt))
        conf = max(mRslt, key=lambda v: v['score'])['score']
        print("{}\t{}\t_conf:{:.12f}".format(key, "\t".join(aOut), conf), flush=True)


if __name__ == '__main__':
    main()
