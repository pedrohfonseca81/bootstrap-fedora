#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/utils.sh"

log_step "07 — Serviços do sistema"
require_root

REAL_USER="${SUDO_USER:-$USER}"

enable_system_service() {
  local svc="$1"
  if systemctl is-enabled "$svc" &>/dev/null; then
    log_success "$svc já habilitado."
  else
    systemctl enable --now "$svc" && log_success "$svc habilitado." || log_warn "Falha ao habilitar $svc"
  fi
}

enable_user_service() {
  local svc="$1"
  if systemctl --user -M "${REAL_USER}@.service" is-enabled "$svc" &>/dev/null 2>&1; then
    log_success "(user) $svc já habilitado."
  else
    su -l "$REAL_USER" -c "systemctl --user enable --now $svc" \
      && log_success "(user) $svc habilitado." \
      || log_warn "Falha ao habilitar serviço de usuário $svc"
  fi
}

# ── Target gráfico (minimal usa multi-user por padrão) ───────────────────────
log_info "Definindo graphical.target como padrão..."
systemctl set-default graphical.target
log_success "graphical.target configurado."

# ── Configuração do SDDM ─────────────────────────────────────────────────────
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF="$SDDM_CONF_DIR/bootstrap.conf"

mkdir -p "$SDDM_CONF_DIR"

if [[ ! -f "$SDDM_CONF" ]]; then
  log_info "Configurando SDDM para Hyprland (Wayland)..."
  cat > "$SDDM_CONF" <<EOF
[General]
DisplayServer=wayland
Numlock=on

[Autologin]
# Descomente para login automático:
#User=${REAL_USER}
#Session=hyprland

[Wayland]
SessionDir=/usr/share/wayland-sessions

[Theme]
Current=breeze

[Users]
RememberLastSession=true
RememberLastUser=true
EOF
  log_success "SDDM configurado em $SDDM_CONF"
else
  log_success "Configuração do SDDM já existe."
fi

# ── Serviços de sistema ───────────────────────────────────────────────────────
enable_system_service sddm          # Display Manager
enable_system_service docker
enable_system_service firewalld
enable_system_service NetworkManager

# ── Adiciona usuário ao grupo docker ─────────────────────────────────────────
if ! groups "$REAL_USER" | grep -q '\bdocker\b'; then
  log_info "Adicionando $REAL_USER ao grupo docker..."
  usermod -aG docker "$REAL_USER"
  log_success "$REAL_USER adicionado ao grupo docker (requer logout/login)."
else
  log_success "$REAL_USER já está no grupo docker."
fi

# ── Serviços de usuário ───────────────────────────────────────────────────────
log_info "Habilitando serviços de usuário para $REAL_USER..."
su -l "$REAL_USER" -c "systemctl --user enable --now pipewire pipewire-pulse wireplumber" \
  && log_success "pipewire + wireplumber habilitados." \
  || log_warn "Alguns serviços de áudio falharam."

log_success "Serviços configurados."
