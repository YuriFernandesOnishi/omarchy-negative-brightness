#!/bin/bash
# Instala o brilho negativo (gamma dimming) no widget de Display do Omarchy.
#
# O que este script faz:
#   1. Clona o plugin "omarchy.monitor" (se ainda não estiver clonado)
#   2. Sobrescreve Panel.qml/Model.js com a versão que suporta:
#        - brilho de -70% a 100% (abaixo de 0% escurece via gamma)
#        - um seletor por monitor no painel de Display
#   3. Instala os scripts auxiliares em ~/.local/bin
#   4. Garante o autoload do plugin hyprgamma no início do Hyprland
#
# O que este script NÃO faz (precisa da sua senha, então é manual):
#   hyprpm add https://github.com/surprizeattackxx-dotcom/hypr-gamma.git
#   hyprpm enable hyprgamma
# Veja o README para o passo a passo completo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v omarchy >/dev/null 2>&1; then
    echo "Este instalador é para o Omarchy (https://omarchy.org). Comando 'omarchy' não encontrado." >&2
    exit 1
fi

echo "==> Clonando (ou reutilizando) o plugin omarchy.monitor..."
PLUGIN_DIR=""
for d in "$HOME/.config/omarchy/plugins/"*.monitor; do
    [[ -d "$d" ]] && PLUGIN_DIR="$d" && break
done

if [[ -z "$PLUGIN_DIR" ]]; then
    omarchy plugin clone omarchy.monitor
    for d in "$HOME/.config/omarchy/plugins/"*.monitor; do
        [[ -d "$d" ]] && PLUGIN_DIR="$d" && break
    done
fi

if [[ -z "$PLUGIN_DIR" ]]; then
    echo "Não consegui localizar o diretório do plugin clonado." >&2
    exit 1
fi

echo "    usando: $PLUGIN_DIR"
cp "$SCRIPT_DIR/plugin/Panel.qml" "$PLUGIN_DIR/Panel.qml"
cp "$SCRIPT_DIR/plugin/Model.js" "$PLUGIN_DIR/Model.js"

echo "==> Instalando scripts auxiliares em ~/.local/bin..."
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/bin/omarchy-brightness-extended" "$HOME/.local/bin/omarchy-brightness-extended"
cp "$SCRIPT_DIR/bin/omarchy-monitor-state-extended" "$HOME/.local/bin/omarchy-monitor-state-extended"
chmod +x "$HOME/.local/bin/omarchy-brightness-extended" "$HOME/.local/bin/omarchy-monitor-state-extended"

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "    aviso: ~/.local/bin não está no seu PATH. Adicione-o no seu shell rc." >&2 ;;
esac

AUTOSTART="$HOME/.config/hypr/autostart.lua"
MARKER="hyprpm reload -n"
if [[ -f "$AUTOSTART" ]] && grep -qF "$MARKER" "$AUTOSTART"; then
    echo "==> autostart.lua já carrega o hyprpm."
else
    echo "==> Adicionando autoload do hyprpm em $AUTOSTART..."
    {
        echo ""
        echo "-- Reload hyprpm plugins (hyprgamma) on every Hyprland start."
        echo "o.exec_on_start(\"$MARKER\")"
    } >> "$AUTOSTART"
fi

echo "==> Reiniciando o shell do Omarchy..."
omarchy restart shell || true

cat <<'EOF'

Pronto. Falta o passo manual (precisa da sua senha de sudo):

    hyprpm add https://github.com/surprizeattackxx-dotcom/hypr-gamma.git
    hyprpm enable hyprgamma

Rode os dois no seu terminal. Depois disso o slider de brilho no painel de
Display (barra) vai de -70% a 100%, com um seletor para escolher qual monitor
ajustar. Veja o README para detalhes e solução de problemas.
EOF
