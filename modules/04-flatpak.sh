#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/utils.sh"

log_step "04 — Flatpak"
require_root
require_internet

FLATPAK_LIST="$(dirname "$0")/../packages/flatpak.txt"

# Garante que flatpak está instalado (pode ter sido instalado no 03, mas por garantia)
if ! command -v flatpak &>/dev/null; then
  log_info "Instalando flatpak..."
  dnf install -y flatpak
fi

# Adiciona Flathub se não estiver configurado
if ! flatpak remote-list 2>/dev/null | grep -q "flathub"; then
  log_info "Adicionando Flathub..."
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  log_success "Flathub adicionado."
else
  log_success "Flathub já configurado."
fi

if [[ ! -f "$FLATPAK_LIST" ]]; then
  log_warn "Lista de flatpaks não encontrada: $FLATPAK_LIST"
  exit 0
fi

mapfile -t apps < <(grep -v '^\s*#' "$FLATPAK_LIST" | grep -v '^\s*$')

if [[ ${#apps[@]} -eq 0 ]]; then
  log_warn "Nenhum app em flatpak.txt"
  exit 0
fi

log_info "Instalando ${#apps[@]} apps Flatpak..."
for app in "${apps[@]}"; do
  if flatpak_installed "$app"; then
    log_success "$app já instalado."
  else
    log_info "Instalando $app..."
    flatpak install -y flathub "$app" || log_warn "$app falhou — pulando."
  fi
done

log_success "Flatpaks instalados."
