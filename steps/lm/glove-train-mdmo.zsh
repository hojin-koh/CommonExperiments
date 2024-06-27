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
description="Train a glove embedding (MDMO)"

setupArgs() {
  opt -r out '()' "Output LM"
  optType out output model

  opt -r in '' "Input text"
  optType in input text
  opt -r vocab '' "Input vocabulary model"
  optType vocab input model

  opt window 15 "window size"
  opt dim '()' "vector dimension"
}

main() {
  if [[ $#out != $#dim ]]; then
    err "Dim and Output must have the same number of parameters" 15
  fi

  local dirTemp
  putTemp dirTemp

  vocab::load \
  | tail -n +3 \
  | awk '{print $2 " " $3}' > $dirTemp/vocab

  in::loadValue \
  | bc/glove/cooccur -verbose 1 \
      -overflow-file $dirTemp/overflow -memory 4.0 \
      -vocab-file $dirTemp/vocab -window-size $window \
  > $dirTemp/cooccur

  cat $dirTemp/cooccur \
  | bc/glove/shuffle -verbose 1 -seed 19890604 \
      -temp-file $dirTemp/shuffletemp -memory 4.0 \
  > $dirTemp/shuffle

  local i
  for (( i=1; i<=$#out; i++ )); do
    local dimThis=${dim[$i]}
    info "Training dimension $dimThis -> ${out[$i]}"

    bc/glove/glove -verbose 1 -save-file $dirTemp/vector-$dimThis \
        -threads $nj -x-max 100 -iter 16 -seed 19890604 \
        -vector-size $dimThis -vocab-file $dirTemp/vocab \
        -input-file $dirTemp/shuffle

    # Tag the model into word2vec format, computing its dimension
    local tag="$(awk '{n=NF-1} END {print NR " " n}' $dirTemp/vector-$dimThis.txt)"
    sed -ri "1i$tag" $dirTemp/vector-$dimThis.txt
    bzip2 -9 $dirTemp/vector-$dimThis.txt

    out::saveCopy $i $dirTemp/vector-$dimThis.txt.bz2
    if [[ $? != 0 ]]; then return 1; fi
  done
}

source Mordio/mordio
