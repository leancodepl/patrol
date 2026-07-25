// Tracks which "program generation" owns the app in develop mode.
//
// A hot restart on web re-runs `main()` inside the same page instead of tearing
// down an isolate, and DDC only generation-gates timers and microtasks — not
// DOM callbacks such as `requestAnimationFrame`. The idle loop that keeps the
// app alive after the last test pumps frames, so without this the previous
// generation's loop keeps rendering into the `EngineFlutterView` that the
// restart disposed, flooding the console with "Trying to render a disposed
// EngineFlutterView."
//
// On non-web platforms a hot restart replaces the whole isolate, so there is
// nothing to invalidate and these are no-ops.
export 'develop_generation_io.dart'
    if (dart.library.js_interop) 'develop_generation_web.dart';
