# Bootstrap Fedora

Configuração de bootstrap para deixar um Fedora minimal do jeito que eu gosto:
Hyprland, Waybar, kitty, rofi, Docker, mise, Zed, Flatpak e meus dotfiles.

Isto não é uma receita universal nem uma distro pronta. É uma base pessoal,
opinativa e em evolução. A ideia é automatizar o que eu sempre acabo fazendo
depois de uma instalação limpa, e este repositório deve mudar conforme eu for
ajustando meu fluxo, trocando ferramentas ou refinando minhas configs.

## O que ele configura

O bootstrap roda em módulos, sempre na mesma ordem:

| Módulo | Função |
| --- | --- |
| `01-network.sh` | valida internet, instala dependências mínimas e atualiza o sistema |
| `02-repos.sh` | adiciona RPM Fusion, COPRs do Hyprland/Starship, Brave e Docker CE |
| `03-packages.sh` | instala pacotes DNF de base, desktop e desenvolvimento |
| `04-flatpak.sh` | configura Flathub e instala apps Flatpak |
| `05-dotfiles.sh` | copia as configurações de `configs/` para o usuário real |
| `06-mise.sh` | instala o `mise` e as versões definidas em `.tool-versions` |
| `07-services.sh` | habilita SDDM, Docker, firewalld, NetworkManager e áudio do usuário |

Os pacotes ficam separados em listas dentro de `packages/`, para facilitar
edição sem precisar mexer na lógica dos scripts.

## Uso

Pré-requisitos:

- Fedora minimal install
- internet funcionando
- usuário com `sudo`

Execute a partir da raiz do repositório:

```bash
sudo bash bootstrap.sh
```

Ao final, reinicie a sessão ou o sistema para aplicar grupos, shell padrão,
serviços de usuário e sessão gráfica.

## Dotfiles

As configurações aplicadas pelo bootstrap ficam em `configs/`:

- Hyprland
- Waybar
- kitty
- rofi
- GTK 3/4
- Starship
- Zed
- mise
- `.zshrc`
- `.profile`

Para capturar as configurações da máquina atual de volta para o repositório:

```bash
bash export-dotfiles.sh
```

Depois disso, revise as mudanças e faça commit dos arquivos atualizados.

> Atenção: o módulo de dotfiles copia os arquivos de `configs/` para o `$HOME`
> e substitui configurações existentes nos mesmos caminhos.

## Atalhos principais

Atalhos definidos no `configs/.config/hypr/hyprland.conf`.

| Atalho | Ação |
| --- | --- |
| `Super + Q` | abrir terminal (`kitty`) |
| `Super + R` | abrir launcher (`rofi`) |
| `Super + E` | abrir gerenciador de arquivos (`thunar`) |
| `Super + C` | fechar janela ativa |
| `Super + M` | sair do Hyprland ou abrir `hyprshutdown`, se disponível |
| `Super + V` / `Super + Space` | alternar janela flutuante |
| `Super + F` | tela cheia |
| `Super + P` | alternar modo pseudo |
| `Super + Shift + Space` | centralizar janela |
| `Super + Shift + E` | abrir menu de logout (`wlogout`) |
| `Super + Shift + S` | screenshot de área e copiar para o clipboard |
| `Super + 1..9` | trocar para workspace |
| `Super + Shift + 1..9` | mover janela para workspace |
| `Super + Setas` | mover foco entre janelas |
| `Super + H/J/K/L` | mover foco entre janelas |
| `Super + Shift + Setas` | mover a janela atual |
| `Super + G` | criar/desfazer grupo de janelas |
| `Super + Tab` | próxima janela no grupo |
| `Super + Shift + Tab` | janela anterior no grupo |
| `Super + Shift + G` | mover janela para dentro do grupo ao lado |
| `Super + =` | aumentar volume |
| `Super + -` | diminuir volume |
| `Super + M` | alternar mute do áudio |
| `XF86AudioRaiseVolume` | aumentar volume |
| `XF86AudioLowerVolume` | diminuir volume |
| `XF86AudioMute` | alternar mute do áudio |
| `XF86AudioMicMute` | alternar mute do microfone |

## Layout inicial

Na sessão do Hyprland, alguns apps são iniciados automaticamente:

- `kitty`
- Firefox
- Thunar
- Zed
- Spotify
- Waybar
- applet do NetworkManager
- Hyprpaper

Também existem regras para organizar janelas por workspace:

| Workspace | App |
| --- | --- |
| `1` | kitty |
| `2` | Firefox |
| `3` | Thunar |
| `4` | Zed |
| `5` | Spotify |

## Estrutura

```text
.
├── bootstrap.sh
├── export-dotfiles.sh
├── configs/
├── lib/
│   └── utils.sh
├── modules/
│   ├── 01-network.sh
│   ├── 02-repos.sh
│   ├── 03-packages.sh
│   ├── 04-flatpak.sh
│   ├── 05-dotfiles.sh
│   ├── 06-mise.sh
│   └── 07-services.sh
└── packages/
    ├── dnf-base.txt
    ├── dnf-desktop.txt
    ├── dnf-extras.txt
    └── flatpak.txt
```

## Notas

- Os scripts usam `set -euo pipefail`.
- Alguns módulos rodam como root, outros reexecutam como usuário real.
- O SDDM é configurado para Wayland e Hyprland.
- Docker é habilitado e o usuário é adicionado ao grupo `docker`.
- Zed é instalado via script oficial quando ainda não existe localmente.
- A fonte JetBrainsMono Nerd Font é instalada para manter ícones e Waybar OK.

Este repositório acompanha meu ambiente. Se algo parecer específico demais, é
porque provavelmente é mesmo.
