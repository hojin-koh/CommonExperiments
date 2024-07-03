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

# Train a FastText model

import os
import sys

from gensim.models.fasttext import FastText

import logging

def main():
    dim = int(sys.argv[1])
    vocab = int(sys.argv[2])
    mincount = int(sys.argv[3])
    winsize = int(sys.argv[4])
    fnameCorpus = sys.argv[5]
    fnameModelOut = sys.argv[6]

    modelFastText = FastText(workers=int(os.getenv("OMP_NUM_THREADS", 3)),
                             sg=1, seed=0x19890604, batch_words=200000, min_n=1, max_n=3,
                             min_count=mincount, max_final_vocab=vocab, window=winsize, vector_size=dim)

    modelFastText.build_vocab(corpus_file=fnameCorpus)
    countWord = modelFastText.corpus_total_words
    print(F"Scanned corpus with {countWord} words", file=sys.stderr)

    # To enable FastText logging
    logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

    modelFastText.train(corpus_file=fnameCorpus, total_words=countWord, epochs=10)
    print(F"FastText model successfully trained", file=sys.stderr)
    modelFastText.save(fnameModelOut)
    print(F"FastText model saved as {fnameModelOut}", file=sys.stderr)

if __name__ == '__main__':
    main()
