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
description="Extract document vector from GloVe model"
dependencies=( "uc/lm/glove-docvec.py" )

setupArgs() {
  opt -r out '' "Output vector"
  optType out output vector

  opt -r in '' "Input text"
  optType in input text
  opt -r model '' "Output LM"
  optType model input model
  opt -r vocab '' "Input vocabulary model"
  optType vocab input model

  opt tfidf '' "Input TF-IDF model"
  optType tfidf input model
}

main() {
  if ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  local nr="$(in::getNR)"
  if [[ -n $tfidf ]]; then
    in::load \
    | uc/lm/glove-docvec.py "$model" "$vocab" "$tfidf" \
    | lineProgressBar $nr \
    | out::save
    return $?
  else
    in::load \
    | uc/lm/glove-docvec.py "$model" "$vocab" \
    | lineProgressBar $nr \
    | out::save
    return $?
  fi
}

source Mordio/mordio
