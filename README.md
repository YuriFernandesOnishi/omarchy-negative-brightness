# omarchy-negative-brightness

Deixa o slider de brilho da barra do [Omarchy](https://omarchy.org) ir abaixo
de 0%, para quem acha o mínimo físico do monitor (DDC/CI) ainda muito claro.

- Faixa: **-70% a 100%** (0% a 100% continua sendo o brilho físico normal;
  abaixo de 0% o monitor fica travado no mínimo físico e o restante é
  escurecimento por gamma, via [hyprgamma](https://github.com/surprizeattackxx-dotcom/hypr-gamma)).
- Painel de Display na barra ganha um **seletor por monitor**: escolha qual
  tela o slider controla sem precisar focar nela primeiro.
- Ajustes abaixo de 0% são rápidos — o comando DDC (lento em alguns
  monitores) só roda uma vez ao cruzar o piso físico, não a cada ajuste.

## Requisitos

- Omarchy instalado.
- Um ou mais monitores com suporte a DDC/CI (a maioria dos monitores externos).
- O plugin de compositor [hyprgamma](https://github.com/surprizeattackxx-dotcom/hypr-gamma),
  que faz o escurecimento por gamma por monitor.

## Instalação

```bash
git clone https://github.com/<seu-usuario>/omarchy-negative-brightness.git
cd omarchy-negative-brightness
./install.sh
```

O `install.sh`:

1. Clona o plugin `omarchy.monitor` da barra (se ainda não tiver um clone seu).
2. Substitui `Panel.qml`/`Model.js` desse clone pela versão com brilho negativo
   e seletor de monitor.
3. Instala os scripts `omarchy-brightness-extended` e
   `omarchy-monitor-state-extended` em `~/.local/bin`.
4. Garante que o `hyprgamma` seja recarregado a cada início do Hyprland
   (`~/.config/hypr/autostart.lua`).
5. Reinicia o shell do Omarchy.

### Passo manual (precisa da sua senha)

O `hyprpm` instala o `.so` do plugin como `root` por segurança (evita que um
processo comprometido troque o binário carregado no compositor), então esse
passo pede senha de sudo interativa e **não pode ser automatizado**:

```bash
hyprpm add https://github.com/surprizeattackxx-dotcom/hypr-gamma.git
hyprpm enable hyprgamma
```

Depois disso, abra o painel de Display na barra — o slider já vai de -70% a
100%, com os botões de monitor acima dele.

## Como funciona

- `bin/omarchy-brightness-extended <monitor> {up|down|max|min|set N}` —
  aplica o valor -70..100 a um monitor: se `N >= 1`, ajusta o brilho físico
  via `omarchy-brightness-display`/DDC; se `N < 1`, trava o físico em 1% e
  aplica `hyprctl hyprgamma:set <monitor> brightness <0.30..1.00>`. Guarda o
  estado por monitor em `~/.local/state/omarchy-brightness/<monitor>`.
- `bin/omarchy-monitor-state-extended` — como o `omarchy-monitor-state`
  nativo do Omarchy, mas troca o brilho de hardware (0-100) pelo valor
  estendido (-70..100) e acrescenta um mapa JSON `{"MONITOR": valor, ...}`
  com o valor de cada monitor, para o painel mostrar o certo ao trocar de
  seletor sem precisar reler o hardware.
- `plugin/Panel.qml` + `plugin/Model.js` — fork do widget `omarchy.monitor`
  original, com faixa -70..100 no slider e uma fileira de botões (um por
  monitor conectado) que troca qual monitor o slider/roda do mouse/atalhos
  de teclado controlam.

## Ajustando o piso mínimo

O piso (-70% = gamma 0.30) é intencional — abaixo disso a tela fica difícil
de enxergar. Para mudar, edite as ocorrências de `-70` em:

- `bin/omarchy-brightness-extended`
- `plugin/Model.js` (`clampBrightness`)
- `plugin/Panel.qml` (`minimum: -70` no `PanelSlider` do brilho)

e rode `./install.sh` de novo (ou copie os arquivos manualmente).

## Desinstalar

```bash
rm -rf ~/.config/omarchy/plugins/*.monitor   # volta pro widget padrão do Omarchy
rm ~/.local/bin/omarchy-brightness-extended ~/.local/bin/omarchy-monitor-state-extended
hyprpm disable hyprgamma   # opcional
omarchy restart shell
```

Remova também a linha `hyprpm reload -n` de `~/.config/hypr/autostart.lua`
se não for mais usar o hyprgamma.

## Créditos

- [hyprgamma](https://github.com/surprizeattackxx-dotcom/hypr-gamma) por
  surprizeattackxx-dotcom — plugin de compositor que faz o gamma dimming
  por monitor.
- [Omarchy](https://omarchy.org) pelo widget original `omarchy.monitor`.
