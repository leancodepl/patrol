# Build Benchmark Analysis

## Android

| Step                   | CLEAN (ms) | CACHED (ms) | % Improvement |
|------------------------|------------|-------------|---------------|
| Test discovery         | 7          | 6           | 14.29%        |
| Test bundle generation | 9          | 8           | 11.11%        |
| Flutter build step     | 2066       | 1424        | 31.07%        |
| Gradle app build step  | 40674      | 3940        | 90.31%        |
| Gradle test build step | 3257       | 1296        | 60.21%        |
| Build completed        | 50266      | 10351       | 79.41%        |

## iOS

| Step                   | CLEAN (ms) | CACHED (ms) | % Improvement |
|------------------------|------------|-------------|---------------|
| Test discovery         | 6          | 6           | 0.00%         |
| Test bundle generation | 9          | 7           | 22.22%        |
| Flutter build step     | 8819       | 4976        | 43.58%        |
| Xcode build step       | 97508      | 24400       | 74.98%        |
| Build completed        | 106330     | 29378       | 72.37%        |

## MacOS

| Step                   | CLEAN (ms) | CACHED (ms) | % Improvement |
|------------------------|------------|-------------|---------------|
| Test discovery         | 6          | 6           | 0.00%         |
| Test bundle generation | 10         | 8           | 20.00%        |
| Flutter build step     | 5991       | 3058        | 48.96%        |
| Xcode build step       | 54503      | 16462       | 69.79%        |
| Build completed        | 60497      | 19522       | 67.72%        |

Average build improvement: 73.17%
