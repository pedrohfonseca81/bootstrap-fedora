#!/usr/bin/env bash
# Bootstrap Fedora — Pedro Fonseca
# Uso: sudo bash bootstrap.sh
# Pré-requisito: Fedora minimal install com acesso à internet.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║       Bootstrap Fedora — Pedro           ║"
echo "  ║   Hyprland · Docker · mise · dotfiles    ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

require_root

# Exporta o diretório do script para os módulos usarem
export BOOTSTRAP_DIR="$SCRIPT_DIR"

run_module() {
  local module="$1"
  local path="$SCRIPT_DIR/modules/${module}"

  if [[ ! -f "$path" ]]; then
    log_error "Módulo não encontrado: $path"
    exit 1
  fi

  bash "$path"
}

# ── Execução em ordem ─────────────────────────────────────────────────────────
run_module 01-network.sh
run_module 02-repos.sh
run_module 03-packages.sh
run_module 04-flatpak.sh
run_module 05-dotfiles.sh    # re-executa como usuário real internamente
run_module 06-mise.sh        # re-executa como usuário real internamente
run_module 07-services.sh

# ── Resumo final ──────────────────────────────────────────────────────────────
echo ""
log_step "Bootstrap concluído!"
echo ""
echo "  Próximos passos:"
echo "  1. Reinicie a sessão (ou o sistema) para aplicar grupos e shell."
echo "  2. Entre no Hyprland via SDDM."
echo "  3. Abra o kitty e verifique: mise list, docker info, zed --version"
echo ""
log_warn "Se o Zed não abrir, execute: curl -f https://zed.dev/install.sh | sh"
