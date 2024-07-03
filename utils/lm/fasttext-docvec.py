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

# Extract FastText document feature by averaging the word vectors

import sys

import numpy as np

from gensim.models import KeyedVectors

def main():
    fnameModel = sys.argv[1]
    fnameVocab = sys.argv[2]
    if len(sys.argv) > 3:
        fnameTfIdf = sys.argv[3]
    else:
        fnameTfIdf = None

    objDict = Dictionary.load_from_text(fnameVocab)
    print(F"Loaded dictionary from {fnameVocab}", file=sys.stderr)

    modelGloVe = KeyedVectors.load_word2vec_format(fnameModel)
    print(F"Loaded GloVe from {fnameModel}", file=sys.stderr)

    if fnameTfIdf:
        modelTfIdf = TfidfModel.load(fnameTfIdf)
        print(F"Loaded TF-IDF {fnameTfIdf}", file=sys.stderr)
    else:
        modelTfIdf = None

    for line in sys.stdin:
        key, text = line.strip().split('\t', 1)
        # Filter out non-words
        aText = tuple(w for w in text.strip().split() if w in objDict.token2id and not w.startswith('<'))
        if len(aText) <= 0:
            vVec = modelGloVe['<unk>']
        else:
            if modelTfIdf:
                vTfIdf = np.array(modelTfIdf[((wid, 1) for wid in objDict.doc2idx(aText))])[:,1]
                vVec = np.average(np.vstack(modelGloVe[aText]), axis=0, weights=vTfIdf)
            else:
                vVec = np.average(np.vstack(modelGloVe[aText]), axis=0)
        print(F'{key}\t' + "\t".join(F'{s:.12f}' for s in vVec))

if __name__ == '__main__':
    main()
