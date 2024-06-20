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

# Extract GloVe document feature by averaging the word vectors through TF-IDF

import sys

import numpy as np

from gensim.corpora import Dictionary
from gensim.models import TfidfModel

def makeGenCorpus(objDict, fd):
    for line in fd:
        yield tuple((idx, 1) for idx in objDict.doc2idx(line.strip().split(), unknown_word_index=1))

def main():
    fnameModel = sys.argv[1]
    fnameVocab = sys.argv[2]

    objDict = Dictionary.load_from_text(fnameVocab)
    print(F"Loaded dictionary from {fnameVocab}", file=sys.stderr)

    modelTfIdf = TfidfModel.load(fnameModel)
    print(F"Loaded TF-IDF from {fnameModel}", file=sys.stderr)

    for line in sys.stdin:
        key, text = line.strip().split('\t', 1)
        # Filter out non-words
        aText = tuple(w for w in text.strip().split() if w in objDict.token2id and not w.startswith('<'))
        if len(aText) <= 0:
            vVec = (0.0,)
        else:
            vVec = np.array(modelTfIdf[((wid, 1) for wid in objDict.doc2idx(aText))])[:,1]
        avg = np.mean(vVec)
        print(F'{key}\t{avg:.12f}')

if __name__ == '__main__':
    main()
