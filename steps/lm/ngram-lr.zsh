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
description="Compute likelihood ratio on LMs"
dependencies=( "uc/num/compute-lr.pl" "uc/num/atan-feats.pl" )

setupArgs() {
  opt -r out '' "Output likelihood vector"
  optType out output vector
  opt -r outoov '' "Output oov-ratio vector"
  optType outoov output vector

  opt -r lm '()' "Input LMs"
  optType lm input model
  opt -r in '' "Input evaluation text"
  optType in input text

  opt lr 'all' "Likelihood-ratio mode. (empty)=output raw log likelihood; all=divide by sum of all; (number)=use the specific 1-based index as background"
  opt normk '50' "Normalize likelihood ratio to between 0-1 with this number as k>0: 1+2*atan(loglikehood/k)/PI"
}

main() {
  if ! out::isReal; then
    err "Unreal vector output not supported" 15
  fi

  local dirTemp
  putTemp dirTemp

  local i
  local fd1
  exec {fd1}< <(in::loadKey)
  local fd2
  exec {fd2}< <(in::loadKey)
  local paramLike=/dev/fd/$fd1
  local paramOOV=/dev/fd/$fd2
  for (( i=1; i<=${#lm[@]}; i++ )); do
    info "Evaluating ${lm[$i]} ..."
    in::loadValue \
    | bc/kenlm/query -v sentence ${lm[$i]} \
    | gawk -vfileOOV=$dirTemp/oov-$i '{print $2; print $4 >> (fileOOV)}' \
    > $dirTemp/like-$i

    paramLike+=" $dirTemp/like-$i"
    paramOOV+=" $dirTemp/oov-$i"
  done

  paste -d$'\t' "${(z)paramLike}" \
  | if [[ -n $lr ]]; then uc/num/compute-lr.pl $lr; else cat; fi \
  | if [[ -n $normk ]]; then uc/num/atan-feats.pl -$normk; else cat; fi \
  | out::save
  if [[ $? != 0 ]]; then return 1; fi

  paste -d$'\t' "${(z)paramOOV}" \
  | gawk -F$'\t' 'BEGIN {OFS="\t"} NR==FNR {nTok[$1] = split($2, tok, " "); next}
      1 {for (i=2; i<=NF; i++) $i/=nTok[$1]; print}' <(in::load) - \
  | outoov::save
  if [[ $? != 0 ]]; then return 1; fi
}

source Mordio/mordio
