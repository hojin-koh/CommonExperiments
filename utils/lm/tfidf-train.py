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

# Based on a table of (bad character)\t(good character) records as argv[1],
# Perform text normalization on text part of (id)\t(text) records (if sys.argv[2]=="text")
# or key part of (key)\t(number) records from stdin (if sys.argv[2]=="key")
# Also will do unicodedata.normalize()

import fileinput
import re
import sys
import unicodedata

from gensim.models import TfidfModel
from gensim.corpora import Dictionary

def makeGeneratorCorpus(objDict, fd):
    for line in fd:
        yield tuple((idx, 1) for idx in objDict.doc2idx(line.strip().split(), unknown_word_index=1))

def main():
    typeSMART = sys.argv[1]
    fnameVocab = sys.argv[2]
    fnameModelOut = sys.argv[3]

    objDict = Dictionary.load_from_text(fnameVocab)
    print(F"Loaded dictionary from {fnameVocab}", file=sys.stderr)

    genCorpus = makeGeneratorCorpus(objDict, sys.stdin)
    modelTfidf = TfidfModel(genCorpus, smartirs=typeSMART, normalize=True)
    modelTfidf.save(fnameModelOut)
    print(F"TF-IDF model saved as {fnameModelOut}", file=sys.stderr)

    for wid in objDict:
        rslt = modelTfidf[((wid, 1),)]
        if len(rslt) == 0: continue
        tfidf = rslt[0][1]
        print("{}\t{:.8f}".format(objDict[wid], tfidf))

if __name__ == '__main__':
    main()
