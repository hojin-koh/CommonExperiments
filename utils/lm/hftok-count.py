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

# Get token count from a HF-compatible tokenizer
# Usage: berttok-count.py <model>

import sys

from transformers import AutoTokenizer

def main():
    nameModel = sys.argv[1]

    objTok = AutoTokenizer.from_pretrained(nameModel, do_lower_case=False, clean_up_tokenization_spaces=False)

    for line in sys.stdin:
        key, text = line.strip().split('\t', 1)
        if len(key) <= 0 or len(text) <= 0: continue
        text = text.replace("\\n", "\n")
        nTok = len(objTok.encode(text, padding=False, truncation=False))
        print("{}\t{:d}".format(key, nTok), flush=True)

if __name__ == '__main__':
    main()
