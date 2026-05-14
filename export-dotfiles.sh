#!/usr/bin/env bash
# Executa na máquina ORIGEM para capturar configs no repo.
# Uso: bash export-dotfiles.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}   $*"; }
log_warn()    { echo -e "${RED}[AVISO]${NC} $*"; }

copy_config() {
  local src="$1"
  local dst_rel="$2"          # relativo a configs/
  local dst="$CONFIGS_DIR/$dst_rel"

  if [[ ! -e "$src" ]]; then
    log_warn "Não encontrado: $src — pulando."
    return
  fi

  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  cp -r "$src" "$dst"
  log_success "$(basename "$src") → configs/$dst_rel"
}

echo -e "\n${BOLD}Exportando dotfiles de $HOME para $CONFIGS_DIR${NC}\n"

mkdir -p "$CONFIGS_DIR/.config"

# ── Shell ─────────────────────────────────────────────────────────────────────
copy_config "$HOME/.zshrc"                         ".zshrc"
copy_config "$HOME/.profile"                       ".profile"

# ── Hyprland ──────────────────────────────────────────────────────────────────
copy_config "$HOME/.config/hypr"                   ".config/hypr"

# ── Waybar ────────────────────────────────────────────────────────────────────
copy_config "$HOME/.config/waybar"                 ".config/waybar"

# ── Terminal ──────────────────────────────────────────────────────────────────
copy_config "$HOME/.config/kitty"                  ".config/kitty"

# ── App launcher ──────────────────────────────────────────────────────────────
copy_config "$HOME/.config/rofi"                   ".config/rofi"

# ── GTK ───────────────────────────────────────────────────────────────────────
copy_config "$HOME/.config/gtk-3.0"                ".config/gtk-3.0"
copy_config "$HOME/.config/gtk-4.0"                ".config/gtk-4.0"

# ── Prompt ────────────────────────────────────────────────────────────────────
copy_config "$HOME/.config/starship.toml"          ".config/starship.toml"

# ── Zed ───────────────────────────────────────────────────────────────────────
copy_config "$HOME/.config/zed"                    ".config/zed"

# ── mise ──────────────────────────────────────────────────────────────────────
copy_config "$HOME/.config/mise/config.toml"       ".config/mise/config.toml"

# ── .tool-versions (raiz do repo) ────────────────────────────────────────────
if [[ -f "$HOME/.config/mise/config.toml" ]]; then
  # Gera .tool-versions a partir do mise config
  if command -v mise &>/dev/null; then
    mise list --current 2>/dev/null \
      | awk '{print $1, $2}' \
      | grep -v '^$' \
      > "$SCRIPT_DIR/.tool-versions" \
      && log_success ".tool-versions gerado via mise list"
  fi
fi

# Fallback: copia o existente
if [[ -f "$HOME/.tool-versions" ]] && [[ ! -f "$SCRIPT_DIR/.tool-versions" ]]; then
  copy_config "$HOME/.tool-versions" "../.tool-versions"
fi

echo ""
log_success "Exportação concluída. Commit os arquivos em configs/ antes de usar o bootstrap."
echo ""
echo "  git add configs/ .tool-versions"
echo "  git commit -m 'feat: exportar dotfiles'"
echo "  git push"
