#!/bin/bash
# Génère le projet Xcode et l’ouvre. Prérequis : brew install xcodegen
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v xcodegen >/dev/null; then
  echo "XcodeGen manquant : brew install xcodegen" && exit 1
fi
xcodegen generate
echo "Projet généré. Pensez aux polices : Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Resources/Fonts/"
open Nutristack.xcodeproj
