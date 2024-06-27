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
description="Extract document vector from GloVe model (MIMO)"
dependencies=( "uc/lm/glove-docvec.py" )

setupArgs() {
  opt -r out '()' "Output vector"
  optType out output vector

  opt -r in '()' "Input text"
  optType in input text
  opt -r model '()' "Output LM"
  optType model input model
  opt -r vocab '()' "Input vocabulary model"
  optType vocab input model

  opt tfidf '()' "Input TF-IDF model"
  optType tfidf input model
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  if [[ $#out != $#in ]]; then
    err "Input and Output must have the same number of parameters" 15
  fi

  if [[ $#model != $#in ]]; then
    err "Input and Model must have the same number of parameters" 15
  fi

  if [[ $#vocab != $#in ]]; then
    err "Input and Vocab must have the same number of parameters" 15
  fi

  if [[ $#tfidf -gt 0 && $#vocab != $#in ]]; then
    err "Input and TFIDF(if specified) must have the same number of parameters" 15
  fi

  local i
  local nr
  for (( i=1; i<=$#in; i++ )); do
    info "Processing file set $i/$#in: ${in[$i]}"

    getMeta in $i nRecord nr
    if [[ -n ${tfidf[$i]-} ]]; then
      in::load $i \
      | uc/lm/glove-docvec.py "${model[$i]}" "${vocab[$i]}" "${tfidf[$i]}" \
      | lineProgressBar $nr \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      in::load $i \
      | uc/lm/glove-docvec.py "${model[$i]}" "${vocab[$i]}" \
      | lineProgressBar $nr \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done
}

source Mordio/mordio
