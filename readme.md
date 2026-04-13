<picture>
  <source media="(prefers-color-scheme: dark)" srcset="/docs/images/TOTEM_logo_dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="/docs/images/TOTEM_logo_bright.svg">
  <img alt="TOTEM logo font" src="/docs/images/TOTEM_logo_bright.svg">
</picture>

# ZMK CONFIG FOR THE TOTEM SPLIT KEYBOARD

[Here](https://github.com/GEIGEIGEIST/totem) you can find the hardware files and build guide.\
[Here](https://github.com/GEIGEIGEIST/qmk-config-totem) you can find the QMK config for the TOTEM.

TOTEM is a 38 key column-staggered split keyboard running [ZMK](https://zmk.dev/) or [QMK](https://docs.qmk.fm/). It's meant to be used with a SEEED XIAO BLE or RP2040.


![TOTEM layout](/docs/images/TOTEM_layout.svg)



## HOW TO USE

- fork this repo
- `git clone` your repo, to create a local copy on your PC (you can use the [command line](https://www.atlassian.com/git/tutorials) or [github desktop](https://desktop.github.com/))
- adjust the totem.keymap file (find all the keycodes on [the zmk docs pages](https://zmk.dev/docs/codes/))
- `git push` your repo to your fork
- on the GitHub page of your fork navigate to "Actions"
- scroll down and unzip the `firmware.zip` archive that contains the latest firmware
- connect the left half of the TOTEM to your PC, press reset twice
- the keyboard should now appear as a mass storage device
- drag'n'drop the `totem_left-seeeduino_xiao_ble-zmk.uf2` file from the archive onto the storage device
- repeat this process with the right half and the `totem_right-seeeduino_xiao_ble-zmk.uf2` file.

## Guide Clair

Ce keymap est pense pour un TOTEM 38 touches avec :

- une couche principale en Ergo-L
- des home row mods en `GASC`
- une couche `NAV` pour la navigation et les chiffres
- une couche `SYM` pour les symboles et les accents
- une couche `SYS` pour Bluetooth, bootloader et systeme
- une couche `GAME` en QWERTY pour jouer
- un fonctionnement base sur le clavier systeme `US-International`

## Reglage Systeme

Pour que les accents fonctionnent comme prevu, il faut configurer le systeme d'exploitation en `US-International`.

### Windows

- `Parametres > Heure et langue > Langue et region`
- ouvrir la langue active
- `Ajouter un clavier`
- choisir `United States-International`
- basculer de disposition avec `Win + Espace`

### macOS

- ajouter `U.S. International - PC`

### Linux

- choisir `English (US, intl., with dead keys)` ou l'equivalent

## Schema Base

Couche `BASE` en Ergo-L :

```text
gauche                           droite
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|  Q  |  C  |  O  |  P  |  W  |  |  J  |  M  |  D  |  '  |  Y  |
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|A/GUI|S/ALT|E/SFT|N/CTL|  F  |  |  L  |R/CTL|T/SFT|I/ALT|U/GUI|
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
| ESC |  Z  |  X  |  -  |  V  |  |  B  |  H  |  G  |  ,  |  .  |
+-----+-----+-----+-----+-----+--+-----+-----+-----+-----+-----+
| SYS |                                |  K  |
+-----+                                +-----+
              +-------+-------+-------+  +-------+-------+-------+
              |  TAB  |NAV/BSP| SPACE |  | ENTER |SYM/DEL| AltGr |
              +-------+-------+-------+  +-------+-------+-------+
```

## Home Row Mods

Les touches de repos portent les modificateurs :

- gauche : `A=Gui`, `S=Alt`, `E=Shift`, `N=Control`
- droite : `R=Control`, `T=Shift`, `I=Alt`, `U=Gui`

Reglage actuel :

- `tapping-term-ms = 200`
- `flavor = "tap-preferred"`

Conseil d'usage :

- tape rapidement pour obtenir la lettre
- maintiens legerement plus longtemps pour obtenir le modificateur
- si tu as trop d'activations accidentelles, augmente `tapping-term-ms` vers `220` ou `230`

## Schema Navigation

Couche `NAV` via le thumb gauche `NAV/BSPC` :

```text
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|  1  |  2  |  3  |  4  |  5  |  |  6  |  7  |  8  |  9  |  0  |
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
| TAB |HOME |PGDN |PGUP | END |  |LEFT |DOWN |  UP |RGHT | DEL |
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|     |     |     |     |     |  |     |     |     |     |     |
+-----+-----+-----+-----+-----+--+-----+-----+-----+-----+-----+
| SYS |                                |     |
+-----+                                +-----+
```

## Schema Symboles

Couche `SYM` via le thumb droit `SYM/DEL` :

```text
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|  !  |  @  |  #  |  $  |  %  |  |  ^  |  &  |  *  |  =  |  +  |
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|  (  |  [  |  {  |  `  |  '  |  |  -  |  }  |  ]  |  )  |  "  |
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|     |  \  |  /  |  ,  |  .  |  |  ;  |  '  |  ç  |  é  |  à  |
+-----+-----+-----+-----+-----+--+-----+-----+-----+-----+-----+
| SYS |                                |  è  |
+-----+                                +-----+
```

## Accents Francais

Deux methodes sont prevues.

### 1. Combos rapides

- `A + S = à`
- `E + R = é`
- `I + O = è`

Ces combos sont actifs sur la couche `BASE`.

### 2. AltGr et couche SYM

Le thumb droit externe est un `AltGr` sticky :

- touche une fois `AltGr`
- puis tape la touche cible

Exemples utiles avec `US-International` :

- `AltGr + E = é`
- `AltGr + C = ç`

Pour `à` et `è`, le keymap envoie la sequence de touche morte grave du layout `US-International`.

## Mode Jeu

Le mode jeu utilise une disposition QWERTY plus classique.

Schema `GAME` :

```text
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|  Q  |  W  |  E  |  R  |  T  |  |  Y  |  U  |  I  |  O  |  P  |
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|  A  |  S  |  D  |  F  |  G  |  |  H  |  J  |  K  |  L  |  ;  |
+-----+-----+-----+-----+-----+  +-----+-----+-----+-----+-----+
|SHIFT|  Z  |  X  |  C  |  V  |  |  B  |  N  |  M  |  ,  |  .  |
+-----+-----+-----+-----+-----+--+-----+-----+-----+-----+-----+
| SYS |                                |  /  |
+-----+                                +-----+
              +-------+-------+-------+  +-------+-------+-------+
              | LCTRL |  TAB  | SPACE |  | SPACE | ENTER |  ESC  |
              +-------+-------+-------+  +-------+-------+-------+
```

Activation du mode jeu :

- appuie simultanement sur les deux touches exterieures de la rangee du bas
- le meme combo desactive aussi `GAME`

## Couche Systeme

La couche `SYS` est accessible avec la touche exterieure basse `SYS`.

Fonctions presentes :

- `BT_SEL 0` a `BT_SEL 3`
- `BT_CLR`
- `BOOTLOADER`
- `SYS_RESET`
- `OUT_TOG`

## Fichiers Utiles

- keymap principal : [`config/totem.keymap`](./config/totem.keymap)
- configuration clavier : [`config/totem.conf`](./config/totem.conf)
- schema materiel : [`docs/images/TOTEM_layout.svg`](./docs/images/TOTEM_layout.svg)
