# Script invoked by the Flutter customer tests repository.

set -e

# Array of relative directories
dirs=("packages/patrol_finders" "packages/patrol" "packages/patrol_cli")

# Loop through each directory
for dir in "${dirs[@]}"; do
  cd "$dir"

  flutter analyze --no-fatal-infos
  flutter test

  cd - > /dev/null # Return to the previous directory
done
