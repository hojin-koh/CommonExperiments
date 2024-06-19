// Copyright 2020-2024, Hojin Koh
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Calculating average error rate (with weight) and bootstrapped 95% confidence interval

#include <algorithm> // for find_if_not
#include <iostream> // for reading stdin
#include <spanstream> // for tab delimiter part
#include <string>
#include <string_view>

#include <vector>
#include <set>
#include <random> // mt19937
#include <limits> // for inf
#include <iomanip> // for printing numbers
#include <cmath> // for std::fabs
//#include <numeric>

const uint64_t NUM_REPEAT_MAX = 50000;
const uint64_t NUM_REPEAT_MIN = 6000;
const uint64_t SIZE_BATCH = 2000;
const double DELTA_CONVERGE = 1E-7;

bool isSpace(char c) {
  return std::isspace(static_cast<unsigned char>(c));
}

std::string_view strip(std::string_view str) {
  auto start = std::find_if_not(str.begin(), str.end(), isSpace);
  auto end = std::find_if_not(str.rbegin(), str.rend(), isSpace).base(); // reverse search for end
  return start == end ? "" : std::string_view(start, end);
}

struct Record {
  double error;
  double weight;
};

//std::vector<Record> readData(const std::string& filename) {
//    std::ifstream file(filename);
//    std::vector<Record> data;
//
//    std::string line;
//    while (std::getline(file, line)) {
//        std::istringstream iss(line);
//        Record record;
//        iss >> record.utteranceId >> record.errorRate >> record.weight;
//        data.push_back(record);
//    }
//
//    return data;
//}
//
//double calculateWeightedErrorRate(const std::vector<Record>& data) {
//    double weightedSum = 0.0;
//    double totalWeight = 0.0;
//
//    for (const auto& record : data) {
//        weightedSum += record.errorRate * record.weight;
//        totalWeight += record.weight;
//    }
//
//    return weightedSum / totalWeight;
//}

int main() {
  std::vector<Record> aRecords;
  for (std::string line; std::getline(std::cin, line);) {
    std::ispanstream iss(strip(line));
    std::string eid, textRest, textError, textWeight;

    std::getline(iss, eid, '\t'); // Read up to the tab delimiter for id
    std::getline(iss, textRest); // Read the rest of the line
    std::ispanstream issRest(strip(textRest));
    std::getline(issRest, textError, '\t');
    if (issRest.eof()) {
      textWeight = "1.0";
    } else {
      std::getline(issRest, textWeight, '\t');
    }

    aRecords.emplace_back(std::stod(textError), std::stod(textWeight));
  }
  uint64_t nRecord = aRecords.size();
  std::cerr << "Loaded " << nRecord << " records.\n";

  // The REAL mean we're going to report at the end
  double meanReal {0.0};
  {
    double countReal {0.0};
    for (uint64_t i=0; i<nRecord; ++i) {
      countReal += aRecords[i].weight;
      meanReal += aRecords[i].weight * (aRecords[i].error - meanReal) / countReal;
    }
  }
  std::cerr << "Mean error rate: " << meanReal << "%\n";


  // Now we have the data, start setting up bootstrap things

  std::mt19937 rngSeeder(0x19890604);
  std::multiset<double> aError;

  double lowerThis;
  double upperThis;
  double lowerPrev {std::numeric_limits<double>::infinity()};
  double upperPrev {std::numeric_limits<double>::infinity()};
  while (true) {
    // Seeds for each instance in this epoch
    std::vector<uint64_t> aSeeds;
    aSeeds.reserve(SIZE_BATCH);
    std::generate_n(std::back_inserter(aSeeds), SIZE_BATCH, [&](){ return rngSeeder(); });

    #pragma omp parallel for
    for (uint64_t k=0; k<SIZE_BATCH; ++k) {
      std::mt19937 rngThis(aSeeds[k]);
      double meanThis {0.0};
      double countThis {0.0};
      for (uint64_t i=0; i<nRecord; ++i) {
        uint64_t idx = rngThis() % nRecord;
        countThis += aRecords[idx].weight;
        meanThis += aRecords[idx].weight * (aRecords[idx].error - meanThis) / countThis;
      }

      #pragma omp critical
      aError.insert(meanThis);
    }

    auto itrError {aError.begin()};
    std::advance(itrError, aError.size()*2.5/100-1);
    lowerThis = *itrError;
    std::advance(itrError, aError.size()*95/100);
    upperThis = *itrError;
    //std::cerr << "Iteration " << aError.size() << std::fixed << std::setprecision(10)
    //  << " (" << lowerThis << ", " << upperThis << ")\n";

    // Converge check
    if (aError.size() >= NUM_REPEAT_MIN) {
      if (aError.size() >= NUM_REPEAT_MAX) break;
      if (std::fabs(lowerThis-lowerPrev) < DELTA_CONVERGE && std::fabs(upperThis-upperPrev) < DELTA_CONVERGE) {
        break;
      }
    }

    lowerPrev = lowerThis;
    upperPrev = upperThis;
  }

  std::cout << std::fixed << std::setprecision(10)
      << meanReal << '\t' << lowerThis << '\t' << upperThis << '\n';
  std::cerr << std::fixed << std::setprecision(10)
      << "95%% CI: (" << lowerThis << "%, " << upperThis << "%)\n";

  return 0;
}

