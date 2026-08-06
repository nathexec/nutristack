#!/bin/bash
# Génère le projet Xcode et l’ouvre.
#
# Prérequis : XcodeGen 2.43.0 exactement. `brew install xcodegen` installe la
# version courante, qui écrit un `objectVersion` que Xcode 15.4 refuse d’ouvrir
# (échec du projet, code de sortie 74). Le contrôle de version ci-dessous existe
# pour que l’échec survienne ici, avec sa cause, plutôt que trois étapes plus
# loin dans Xcode. La CI épingle la même version, voir `.github/actions/toolchain`.
set -euo pipefail
cd "$(dirname "$0")/.."

XCODEGEN_ATTENDU="2.43.0"

marche_a_suivre() {
  cat <<EOF
Installation de XcodeGen $XCODEGEN_ATTENDU (n’utilisez pas 'brew install xcodegen') :

  curl -fsSL -o /tmp/xcodegen.zip \\
    https://github.com/yonaskolb/XcodeGen/releases/download/$XCODEGEN_ATTENDU/xcodegen.zip
  unzip -q -o /tmp/xcodegen.zip -d /tmp/xcodegen
  bin="\$(find /tmp/xcodegen -type f -name xcodegen | head -1)"
  chmod +x "\$bin"
  export PATH="\$(dirname "\$bin"):\$PATH"

Le binaire lit ses gabarits dans le dossier « share » voisin : ajoutez son
dossier au PATH, ne le déplacez pas. Même procédure qu’en CI, voir
.github/actions/toolchain/action.yml.
EOF
}

if ! command -v xcodegen >/dev/null; then
  echo "XcodeGen manquant."
  marche_a_suivre
  exit 1
fi

VERSION_INSTALLEE="$(xcodegen --version | awk '{print $NF}')"
if [ "$VERSION_INSTALLEE" != "$XCODEGEN_ATTENDU" ]; then
  echo "XcodeGen $VERSION_INSTALLEE installé, $XCODEGEN_ATTENDU attendu."
  echo "Les versions 2.44 et suivantes produisent un projet que Xcode 15.4 refuse d’ouvrir."
  marche_a_suivre
  exit 1
fi

xcodegen generate
echo "Projet généré. Pensez aux polices : Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Resources/Fonts/"
open Nutristack.xcodeproj
