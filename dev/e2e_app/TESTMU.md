# Running Patrol tests on TestMu (formerly LambdaTest)

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) installed
- [Patrol CLI](https://patrol.leancode.co/documentation/getting-started) installed (`dart pub global activate patrol_cli`)
- `jq` installed (`brew install jq` on macOS)
- TestMu account with username and access key (get it from [TestMu dashboard](https://accounts.lambdatest.com/security))

## Setup

1. Clone the repo and checkout the branch:

```bash
git clone https://github.com/leancodepl/patrol.git
cd patrol
git checkout testmu/setup
```

2. Navigate to the e2e app:

```bash
cd dev/e2e_app
```

3. Install Flutter dependencies:

```bash
flutter pub get
```

4. Set your TestMu credentials:

```bash
export TESTMU_CREDENTIALS="<username>:<accessKey>"
```

## Running tests

Run a single test:

```bash
./run_android_testmu --target patrol_test/example_test.dart
```

## Reproducing the geolocation issue

TestMu supports IP Geolocation via the `geoLocation` parameter in the build payload.
To reproduce the issue, set `TESTMU_GEOLOCATION` to `FR`:

```bash
TESTMU_GEOLOCATION=FR ./run_android_testmu --target patrol_test/mock_location_test.dart
```

Supported Android country codes: `AU`, `AT`, `BE`, `BR`, `GB`, `BG`, `CA`, `HR`, `CZ`,
`DK`, `EG`, `FI`, `FR`, `DE`, `GR`, `HK`, `HU`, `IN`, `ID`, `IE`, `IL`, `IT`, `JP`,
`KR`, `LV`, `LI`, `LT`, `ES`, `NL`, `NZ`, `NO`, `PH`, `PL`, `PT`, `CN`, `RO`, `RU`,
`RS`, `SG`, `SK`, `SI`, `SE`, `CH`, `TW`, `TH`, `TR`, `UA`, `US`, `VN`, `ZA`.
