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

from gensim.models.fasttext import FastText

def main():
    fnameModel = sys.argv[1]

    modelFastText = FastText.load(fnameModel)
    print(F"Loaded FastText from {fnameModel}", file=sys.stderr)

    for line in sys.stdin:
        key, text = line.strip().split('\t', 1)
        # Filter out non-words
        aText = tuple(w for w in text.strip().split() if not w.startswith('<'))
        if len(aText) <= 0:
            vVec = modelFastText.wv['<unk>']
        else:
            vVec = np.average(np.vstack(modelFastText.wv[aText]), axis=0)
        print(F'{key}\t' + "\t".join(F'{s:.12f}' for s in vVec))

if __name__ == '__main__':
    main()
