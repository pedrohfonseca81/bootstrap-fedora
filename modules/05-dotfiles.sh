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

link_or_copy() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    log_warn "Symlink já existe: $dst — substituindo."
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    log_warn "Backup de $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  if command -v stow &>/dev/null; then
    # Stow cuida do link, nada a fazer aqui (chamado uma vez por pacote)
    return 0
  else
    cp -r "$src" "$dst"
    log_success "Copiado: $dst"
  fi
}

# ── Usa stow se disponível ────────────────────────────────────────────────────
if command -v stow &>/dev/null; then
  log_info "Usando GNU Stow para linkar configs..."
  stow --dir="$CONFIGS_DIR" --target="$HOME" --restow . 2>&1 | grep -v '^$' || true
  log_success "Stow concluído."
else
  # ── Fallback: cópia manual ────────────────────────────────────────────────
  log_info "stow não encontrado — copiando configs manualmente..."

  [[ -d "$CONFIGS_DIR/.config/hypr"     ]] && link_or_copy "$CONFIGS_DIR/.config/hypr"     "$HOME/.config/hypr"
  [[ -d "$CONFIGS_DIR/.config/waybar"   ]] && link_or_copy "$CONFIGS_DIR/.config/waybar"   "$HOME/.config/waybar"
  [[ -d "$CONFIGS_DIR/.config/kitty"    ]] && link_or_copy "$CONFIGS_DIR/.config/kitty"    "$HOME/.config/kitty"
  [[ -d "$CONFIGS_DIR/.config/rofi"     ]] && link_or_copy "$CONFIGS_DIR/.config/rofi"     "$HOME/.config/rofi"
  [[ -d "$CONFIGS_DIR/.config/gtk-3.0"  ]] && link_or_copy "$CONFIGS_DIR/.config/gtk-3.0"  "$HOME/.config/gtk-3.0"
  [[ -d "$CONFIGS_DIR/.config/gtk-4.0"  ]] && link_or_copy "$CONFIGS_DIR/.config/gtk-4.0"  "$HOME/.config/gtk-4.0"
  [[ -d "$CONFIGS_DIR/.config/zed"      ]] && link_or_copy "$CONFIGS_DIR/.config/zed"      "$HOME/.config/zed"
  [[ -f "$CONFIGS_DIR/.config/starship.toml" ]] && link_or_copy "$CONFIGS_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
  [[ -f "$CONFIGS_DIR/.zshrc"           ]] && link_or_copy "$CONFIGS_DIR/.zshrc"           "$HOME/.zshrc"

  log_success "Configs copiadas."
fi

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
