#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}   $*"; }
log_warn()    { echo -e "${YELLOW}[AVISO]${NC} $*"; }
log_error()   { echo -e "${RED}[ERRO]${NC}  $*" >&2; }
log_step()    { echo -e "\n${BOLD}══════════════════════════════════════${NC}"; echo -e "${BOLD} $*${NC}"; echo -e "${BOLD}══════════════════════════════════════${NC}"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "Este módulo precisa ser executado como root (sudo)."
    exit 1
  fi
}

require_internet() {
  log_info "Verificando conexão com a internet..."
  local -a urls=("https://fedoraproject.org" "https://1.1.1.1" "https://8.8.8.8")
  for url in "${urls[@]}"; do
    if curl -fsS --max-time 5 "$url" > /dev/null 2>&1; then
      log_success "Internet disponível."
      return 0
    fi
  done
  log_error "Sem acesso à internet. Verifique sua conexão e tente novamente."
  exit 1
}

pkg_installed() {
  rpm -q "$1" &>/dev/null
}

flatpak_installed() {
  flatpak list --app --columns=application 2>/dev/null | grep -q "^${1}$"
}

copr_enabled() {
  dnf copr list 2>/dev/null | grep -q "$1"
}

ask_confirm() {
  local prompt="${1:-Continuar?}"
  local response
  read -r -p "${prompt} [s/N] " response
  [[ "$response" =~ ^[sS]$ ]]
}
