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

import re
import sys

def main():
    thresLenSent = int(sys.argv[1])
    sys.argv.pop(1)

    if len(sys.argv) > 1:
        reAdditional = "|".join(sys.argv[1:]) + "|"
    else:
        reAdditional = ""
    reSplit = re.compile(R"((?:{}。|；|;|？|\?|！|!|\\n)+)".format(reAdditional))
    for line in sys.stdin:
        eid, text = line.split('\t', 1)
        eid = eid.removesuffix('.txt')
        text = text.strip()

        idSent = 0
        aSent = reSplit.split(text)
        # Recombine the punctuation and 
        aSent = [''.join(x) for x in zip(aSent[0::2], aSent[1::2])]
        for sent in aSent:
            sent = sent.strip().removesuffix("\\n")
            if len(sent) < thresLenSent:
                continue
            print(F"{eid}-s{idSent:06d}.txt\t{sent}")
            idSent += 1

        if idSent == 0: # Absolutely nothing had been output
            print(F"{eid}-s{0:06d}.txt\t{text}")

if __name__ == '__main__':
    main()
