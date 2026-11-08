#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")/../.."
mkdir -p .build/integration
swiftc -module-cache-path .build/clang-cache \
 Sources/Snowhush/{SnowSimulation,SnowLayer,Preferences,HalloweenSign,HalloweenPumpkin,Shaders}.swift \
 Tests/Integration/{WindowTypes,PublicModes}.swift -o .build/integration/public-modes
.build/integration/public-modes "$@"
