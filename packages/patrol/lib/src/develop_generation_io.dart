/// Claims the current program generation. Always 0 off the web, where a hot
/// restart replaces the isolate and leaves nothing behind to invalidate.
int claimDevelopGeneration() => 0;

/// Whether [generation] is still the generation that owns the app. Always true
/// off the web — see [claimDevelopGeneration].
bool isCurrentDevelopGeneration(int generation) => true;
