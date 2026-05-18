#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/utils.sh"

log_step "05 — Dotfiles / Configurações"

# Roda como usuário comum (não root)
if [[ $EUID -eq 0 ]]; then
  REAL_USER="${SUDO_USER:-}"
  if [[ -z "$REAL_USER" ]]; then
    log_error "Não foi possível determinar o usuário real. Execute com sudo a partir do usuário correto."
    exit 1
  fi
  # Re-executa o script como o usuário real
  exec su -l "$REAL_USER" -c "bash $(realpath "$0")"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

if [[ ! -d "$CONFIGS_DIR" ]]; then
  log_warn "Diretório configs/ não encontrado em $CONFIGS_DIR"
  log_warn "Execute export-dotfiles.sh na máquina de origem primeiro."
  exit 0
fi

deploy() {
  local src="$1"
  local dst="$2"

  [[ -e "$src" ]] || { log_warn "Não encontrado: $src — pulando."; return; }

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" || -L "$dst" ]]; then
    rm -rf "$dst"
  fi

  cp -r "$src" "$dst"
  log_success "$(basename "$src") → $dst"
}

log_info "Copiando configs..."
deploy "$CONFIGS_DIR/.config/hypr"          "$HOME/.config/hypr"
deploy "$CONFIGS_DIR/.config/waybar"        "$HOME/.config/waybar"
deploy "$CONFIGS_DIR/.config/kitty"         "$HOME/.config/kitty"
deploy "$CONFIGS_DIR/.config/rofi"          "$HOME/.config/rofi"
deploy "$CONFIGS_DIR/.config/gtk-3.0"       "$HOME/.config/gtk-3.0"
deploy "$CONFIGS_DIR/.config/gtk-4.0"       "$HOME/.config/gtk-4.0"
deploy "$CONFIGS_DIR/.config/zed"           "$HOME/.config/zed"
deploy "$CONFIGS_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
deploy "$CONFIGS_DIR/.config/mise"          "$HOME/.config/mise"
deploy "$CONFIGS_DIR/.config/xdg-desktop-portal" "$HOME/.config/xdg-desktop-portal"
deploy "$CONFIGS_DIR/.zshrc"                "$HOME/.zshrc"
deploy "$CONFIGS_DIR/.profile"              "$HOME/.profile"
log_success "Configs copiadas."

# ── JetBrainsMono Nerd Font (necessário para ícones do waybar) ───────────────
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
if [[ ! -d "$FONT_DIR" ]]; then
  log_info "Instalando JetBrainsMono Nerd Font..."
  mkdir -p "$FONT_DIR"
  curl -fsSL \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
    -o /tmp/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR/" > /dev/null
  rm /tmp/JetBrainsMono.zip
  fc-cache -fv "$FONT_DIR" > /dev/null
  log_success "JetBrainsMono Nerd Font instalada."
else
  log_success "JetBrainsMono Nerd Font já instalada."
fi

# ── Instala Zed (não está nos repos, binário local) ───────────────────────────
if [[ ! -f "$HOME/.local/zed.app/libexec/zed-editor" ]]; then
  log_info "Instalando Zed editor..."
  require_internet() { curl -fsS --max-time 5 https://zed.dev > /dev/null 2>&1 || { echo "Sem internet para Zed" >&2; return 1; }; }
  if curl -f https://zed.dev/install.sh | sh; then
    log_success "Zed instalado."
  else
    log_warn "Instalação do Zed falhou — instale manualmente depois."
  fi
else
  log_success "Zed já instalado."
fi

log_success "Dotfiles aplicados."
