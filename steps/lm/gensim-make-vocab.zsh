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
description="Make a gensim-compatible vocab list through gensim (MIMO)"
importantconfig=(mincount vocab)

setupArgs() {
  opt -r out '()' "Output vocabulary"
  optType out output model

  opt -r in '()' "Input text"
  optType in input text
  opt mincount 5 "min count to be included"
  opt vocab 25000 "vocab size"
}

main() {
  if [[ $#out != $#in ]]; then
    err "Input and Output must have the same number of parameters" 15
  fi

  local dirTemp
  putTemp dirTemp

  local i
  for (( i=1; i<=$#out; i++ )); do
    info "Processing file set $i/$#in: ${in[$i]}"

    in::loadValue $i \
    | bc/glove/vocab_count -verbose 1 \
        -min-count $mincount -max-vocab $vocab > "$dirTemp/vocab"

    (
      perl -CSAD -lane 'BEGIN{$n=0} $n+=$F[1]; END{print $n+1}' $dirTemp/vocab
      printf '1\t%s\t1\n' "<unk>"
      perl -CSAD -lane 'print $.+1, "\t", $F[0], "\t", $F[1]' $dirTemp/vocab
    ) | out::save $i
    if [[ $? != 0 ]]; then return 1; fi
  done

}

source Mordio/mordio
