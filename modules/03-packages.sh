#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/utils.sh"

log_step "03 — Pacotes DNF"
require_root
require_internet

PKGDIR="$(dirname "$0")/../packages"

install_from_list() {
  local list_file="$1"
  local label="$2"

  if [[ ! -f "$list_file" ]]; then
    log_warn "Lista não encontrada: $list_file"
    return
  fi

  # Lê pacotes ignorando comentários e linhas em branco
  local pkgs
  mapfile -t pkgs < <(grep -v '^\s*#' "$list_file" | grep -v '^\s*$')

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    log_warn "Nenhum pacote em $list_file"
    return
  fi

  log_info "Instalando $label (${#pkgs[@]} pacotes)..."
  dnf install -y "${pkgs[@]}" || {
    log_warn "Alguns pacotes de $label falharam — continuando..."
  }
  log_success "$label instalados."
}

# Ordem importa: base → desktop → extras (extras depende de repos do 02)
install_from_list "$PKGDIR/dnf-base.txt"    "pacotes base"
install_from_list "$PKGDIR/dnf-desktop.txt" "pacotes desktop (Hyprland)"
install_from_list "$PKGDIR/dnf-extras.txt"  "pacotes extras (Docker, Brave, Dev)"

# Define zsh como shell padrão se ainda não for
REAL_USER="${SUDO_USER:-$USER}"
CURRENT_SHELL=$(getent passwd "$REAL_USER" | cut -d: -f7)
ZSH_PATH=$(command -v zsh)

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  log_info "Definindo zsh como shell padrão para $REAL_USER..."
  chsh -s "$ZSH_PATH" "$REAL_USER"
  log_success "Shell padrão alterado para zsh."
else
  log_success "zsh já é o shell padrão."
fi

log_success "Instalação de pacotes DNF concluída."
