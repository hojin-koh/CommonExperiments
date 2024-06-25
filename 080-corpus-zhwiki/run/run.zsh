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
description="Main run script to get an usable set of zhwiki data"


main() {
  local DIR="ds"
  local LEX="mc/lexicon"
  local PUB="dc/zhwiki"
  local DIR_DOWNLOAD="craw"

  mkdir -p "$DIR_DOWNLOAD"
  mkdir -p "$PUB"

  # Get the raw corpus
  WIKIVER=20240601
  ss/import-zhwiki.zsh out="$DIR/rawtext-zhwiki.txt.zst" \
    ver="$WIKIVER" in="$DIR_DOWNLOAD/zhwiki-$WIKIVER-pages-articles.xml.bz2"

  ss/process-zhwiki.zsh out="$DIR/text-zhwiki.txt.zst" \
    in="$DIR/rawtext-zhwiki.txt.zst" \

  sc/normalize-unicode-text.zsh out="$PUB/text-doc.txt.zst" \
    conv="$LEX/tw-variants-v1.zst" in="$DIR/text-zhwiki.txt.zst"

  sc/text-split-sent-zh.zsh out="$PUB/text-sent.txt.zst" \
    in="$PUB/text-doc.txt.zst"

  # Output the document-sentence mappings
  sc/table-gen-perl.zsh out="$PUB/map-sent-doc.zst" \
    rule='s/^(([^\t]+)-s[0-9]+.txt)\t.*/$1\t$2.txt/; print' \
    in="$PUB/text-sent.txt.zst"

  sc/table-rev-map.zsh out="$PUB/map-doc-sent.zst" \
    in="$PUB/map-sent-doc.zst"

  # Segment sentence-level text
  sc/text-seg-words.zsh out="$PUB/w-sent.txt.zst" \
    dict="$LEX/tw-dict-mini-v1.zst" freq="$LEX/tw-charfreq-v1.zst" \
    in="$PUB/text-sent.txt.zst"

  sc/text-seg-chars.zsh out="$PUB/c-sent.txt.zst" \
    in="$PUB/text-sent.txt.zst"
}

source Mordio/mordio
