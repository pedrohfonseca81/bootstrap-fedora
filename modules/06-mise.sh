#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/utils.sh"

log_step "06 — mise (toolchain de linguagens)"

# Roda como usuário comum
if [[ $EUID -eq 0 ]]; then
  REAL_USER="${SUDO_USER:-}"
  if [[ -z "$REAL_USER" ]]; then
    log_error "Não foi possível determinar o usuário real."
    exit 1
  fi
  exec su -l "$REAL_USER" -c "bash $(realpath "$0")"
fi

require_internet

MISE_BIN="$HOME/.local/bin/mise"
TOOL_VERSIONS="$(dirname "$0")/../.tool-versions"

# ── Instala mise ──────────────────────────────────────────────────────────────
if [[ ! -x "$MISE_BIN" ]]; then
  log_info "Instalando mise..."
  curl -fsSL https://mise.run | sh
  log_success "mise instalado."
else
  log_success "mise já instalado ($(${MISE_BIN} --version))."
fi

# ── Copia .tool-versions para o home se ainda não existir ────────────────────
if [[ -f "$TOOL_VERSIONS" ]] && [[ ! -f "$HOME/.tool-versions" ]]; then
  cp "$TOOL_VERSIONS" "$HOME/.tool-versions"
  log_info "Copiado .tool-versions para $HOME"
fi

# ── Copia mise config ─────────────────────────────────────────────────────────
MISE_CONFIG_SRC="$(dirname "$0")/../configs/.config/mise/config.toml"
MISE_CONFIG_DST="$HOME/.config/mise/config.toml"

if [[ -f "$MISE_CONFIG_SRC" ]] && [[ ! -f "$MISE_CONFIG_DST" ]]; then
  mkdir -p "$HOME/.config/mise"
  cp "$MISE_CONFIG_SRC" "$MISE_CONFIG_DST"
  log_info "Copiado mise config.toml"
fi

# ── Instala todas as ferramentas definidas ────────────────────────────────────
log_info "Instalando ferramentas via mise (erlang, elixir, node, yarn)..."
log_warn "Isso pode demorar alguns minutos na primeira vez."

"$MISE_BIN" install --yes 2>&1 | while IFS= read -r line; do
  echo "  $line"
done

log_success "Ferramentas mise instaladas."

# ── Garante que mise está ativado no .zshrc ───────────────────────────────────
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]] && ! grep -q 'mise activate' "$ZSHRC"; then
  echo '' >> "$ZSHRC"
  echo 'eval "$($HOME/.local/bin/mise activate zsh)"' >> "$ZSHRC"
  log_info "Adicionado mise activate ao .zshrc"
fi
