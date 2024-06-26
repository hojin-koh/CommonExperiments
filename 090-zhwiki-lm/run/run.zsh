#!/usr/bin/env zsh
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
description="Train some basic word embeddings on zh-wiki data"

DIR="ds"
MODEL="mc/lm-zhwiki"
CORPUS="dc/zhwiki"

main() {
  mkdir -p "$MODEL"

  # Filter out things we don't want trained
  sc/text-excleanup-zh.zsh out="$DIR/w-train.txt.zst" \
    in="$CORPUS/w-sent.txt.zst"

  # Generate a vocabulary for all models to use
  sc/lm/gensim-make-vocab.zsh out="$MODEL/vocab.bz2" \
    --vocab=50000 \
    in="$DIR/w-train.txt.zst"

  # === 000: TF-IDF ===

  sc/lm/tfidf-train.zsh out="$MODEL/tfidf.bz2" outTable="$MODEL/tfidf-table.zst" \
    vocab="$MODEL/vocab.bz2" in="$DIR/w-train.txt.zst"

  # === 010: GloVe ===

  sc/lm/glove-train.zsh out="$MODEL/glove-50.bz2" \
    --dim=50 \
    vocab="$MODEL/vocab.bz2" in="$DIR/w-train.txt.zst"
}

source Mordio/mordio
