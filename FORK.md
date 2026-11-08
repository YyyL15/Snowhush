# Public fork

This repository integrates the original `feat/knife-storm`, `feat/dandelion`, and
`feat/fireflies` branches. All three additions are **macOS only**. Windows and Linux
keep their existing features; producing installers does not port these modes.

The upstream copyright notices and PolyForm Noncommercial license remain in place.

## Local build and checks

- macOS: `./build.sh` produces `build/Snowhush.app` for Apple silicon and Intel.
- `./Tests/Integration/run.sh --require-metal` checks all seven modes, compiles the
  Metal shaders, and reads Swift sprite data on the GPU to verify offsets/stride.
- On hosts with only Command Line Tools, the build may need
  `./build.sh --disable-sandbox -debug-info-format none` and writable module caches.

The public macOS bundle ID is `io.github.YyyL15.Snowhush`. Sparkle stays disabled
until this fork has its own update feed and EdDSA public key. Windows update checks
point to `YyyL15/Snowhush`. Neither distribution should install upstream updates over
fork features. The old publishing script is intentionally disabled because it
pushes upstream branches, releases, and a Homebrew tap.

## Release work still required

No release is published by the local integration work. Before publishing:

1. Use a tag-pinned, single workflow that builds all three platforms and gathers
   artifacts into a draft release. Publish only after every job succeeds.
2. macOS: universal `.dmg`, Developer ID signing and notarization for normal
   distribution; local builds are ad hoc signed. Configure the fork's own Sparkle
   signing key and feed before enabling updates.
3. Windows: x64 `Snowhush-Setup.exe`; build the app first, then the `setup` feature
   with `SNOWHUSH_APP` pointing at that binary. Configure signing separately.
4. Linux: use the existing Ubuntu 22.04 packaging script for `.deb`, `.rpm`,
   AppImage, and checksums. Existing Wayland compositor requirements still apply.
5. Set a new version consistently across platforms, verify installer behavior on
   each OS, and review release notes and checksums before publication.

The inherited Linux release workflow is manual-only and checks out the requested
release tag. It is a temporary packaging helper, not a complete release pipeline.
