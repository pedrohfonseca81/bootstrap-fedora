#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/utils.sh"

log_step "02 — Repositórios"
require_root
require_internet

FEDORA_VER=$(rpm -E %fedora)

# ── RPM Fusion (Free + NonFree) ───────────────────────────────────────────────
if ! rpm -q rpmfusion-free-release &>/dev/null; then
  log_info "Adicionando RPM Fusion Free..."
  dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm"
else
  log_success "RPM Fusion Free já configurado."
fi

if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
  log_info "Adicionando RPM Fusion NonFree..."
  dnf install -y \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"
else
  log_success "RPM Fusion NonFree já configurado."
fi

# ── COPR: solopasha/hyprland ──────────────────────────────────────────────────
if ! ls /etc/yum.repos.d/*solopasha* &>/dev/null; then
  log_info "Habilitando COPR solopasha/hyprland..."
  dnf copr enable -y solopasha/hyprland
else
  log_success "COPR solopasha/hyprland já configurado."
fi

# ── COPR: ashbuk/Hyprland-Fedora (hyprutils, hyprpaper, etc.) ────────────────
if ! ls /etc/yum.repos.d/*ashbuk* &>/dev/null; then
  log_info "Habilitando COPR ashbuk/Hyprland-Fedora..."
  dnf copr enable -y ashbuk/Hyprland-Fedora
else
  log_success "COPR ashbuk/Hyprland-Fedora já configurado."
fi

# ── COPR: atim/starship ───────────────────────────────────────────────────────
if ! ls /etc/yum.repos.d/*atim* &>/dev/null; then
  log_info "Habilitando COPR atim/starship..."
  dnf copr enable -y atim/starship
else
  log_success "COPR atim/starship já configurado."
fi

# ── Brave Browser ─────────────────────────────────────────────────────────────
if [[ ! -f /etc/yum.repos.d/brave-browser.repo ]]; then
  log_info "Adicionando repositório Brave Browser..."
  rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
  dnf config-manager addrepo \
    --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
else
  log_success "Repositório Brave já configurado."
fi

# ── Docker CE ─────────────────────────────────────────────────────────────────
if [[ ! -f /etc/yum.repos.d/docker-ce.repo ]]; then
  log_info "Adicionando repositório Docker CE..."
  dnf config-manager addrepo \
    --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
else
  log_success "Repositório Docker já configurado."
fi

log_info "Atualizando cache dos repositórios..."
dnf makecache

log_success "Todos os repositórios configurados."
