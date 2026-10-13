#!/bin/bash
# Instala Flutter (y con él Dart) y Very Good CLI en las sesiones de
# Claude Code en la nube, para poder correr analyze y tests, y para que
# funcionen los servidores MCP de los plugins dart-flutter y
# vgv-ai-flutter-plugin.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FLUTTER_HOME="/opt/flutter"
PUB_CACHE_BIN="$HOME/.pub-cache/bin"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  archive=$(curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json \
    | jq -r '.current_release.stable as $h | .releases[] | select(.hash == $h) | .archive')
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/$archive" \
    | tar -xJ -C /opt
  git config --global --add safe.directory "$FLUTTER_HOME"
fi

export PATH="$FLUTTER_HOME/bin:$PUB_CACHE_BIN:$PATH"
flutter config --no-analytics >/dev/null
dart --disable-analytics >/dev/null
flutter precache --web >/dev/null

if ! command -v very_good >/dev/null; then
  dart pub global activate very_good_cli >/dev/null
fi

# Los servidores MCP de los plugins se lanzan con "dart" y "very_good"
# desde el PATH del sistema, no desde el de Bash.
ln -sf "$FLUTTER_HOME/bin/flutter" /usr/local/bin/flutter
ln -sf "$FLUTTER_HOME/bin/dart" /usr/local/bin/dart
ln -sf "$PUB_CACHE_BIN/very_good" /usr/local/bin/very_good

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_HOME/bin:$PUB_CACHE_BIN:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

cd "$CLAUDE_PROJECT_DIR"
flutter pub get
