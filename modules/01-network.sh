#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/utils.sh"

log_step "01 — Verificação de rede"
require_root

# Garante que curl está disponível (mínimo pode não ter)
if ! command -v curl &>/dev/null; then
  log_info "Instalando curl..."
  dnf install -y curl
fi

require_internet

# Garante dnf5-plugins (necessário para 'dnf copr enable')
if ! rpm -q dnf5-plugins &>/dev/null && ! rpm -q dnf-plugins-core &>/dev/null; then
  log_info "Instalando dnf5-plugins..."
  dnf install -y dnf5-plugins
fi

# Atualiza o sistema antes de qualquer coisa
log_info "Atualizando sistema base..."
dnf upgrade -y --refresh

log_success "Rede e sistema base OK."
