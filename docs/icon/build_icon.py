"""Génère l'icône Nutristack : SVG maître, exports PNG et planche de contrôle.

Concept : la jauge d'actif, élément signature du Design System (DS §1 et §7),
répétée trois fois. Le remplissage plein est l'actif élémentaire réellement
apporté, la piste hachurée à 45° est le reste du composé. Les trois fractions
sont celles du catalogue : 12,5 % pour le bisglycinate de magnésium, 60 % pour
les oméga-3 en triglycérides, 100 % pour la créatine monohydrate.

Géométrie : la piste mesure 672 pour une hauteur de barre de 84, soit un
rapport de 8 pour 1. Conséquence voulue : une fraction de 12,5 % vaut
exactement la hauteur de la barre et se dessine en disque parfait.

Rendu de la matière, en trois dispositifs et sans aucun filtre SVG, que les
rasteriseurs légers ignorent :
  · le fond reçoit un dégradé linéaire et une lueur radiale décentrée, ce qui
    place une source de lumière en haut à gauche ;
  · la piste est creusée, par un dégradé sombre en haut et clair en bas qui la
    fait lire comme une rainure et non comme un aplat ;
  · le remplissage porte une ombre douce, obtenue en empilant des capsules de
    plus en plus larges et de plus en plus pâles, ce qui simule un flou tout en
    restant du dessin vectoriel pur.
"""
import pathlib
import cairosvg
from PIL import Image, ImageDraw
import numpy as np

CANVAS = 1024
TRACK_W = 672                                     # 65,6 % du canevas
BAR_H = 84                                        # rapport de 8 pour 1
GAP = 100                                         # légèrement supérieur à la barre
X0 = (CANVAS - TRACK_W) // 2                      # 176, marges latérales généreuses
TOTAL_H = 3 * BAR_H + 2 * GAP                     # 452
Y0 = (CANVAS - TOTAL_H) // 2 - 8                  # 278, centrage optique
FRACTIONS = [0.125, 0.60, 1.00]                   # bisglycinate, triglycérides, monohydrate

HATCH_STEP = 26
HATCH_W = 5
SHADOW_LAYERS = 8                                 # empilement simulant le flou

VARIANTS = {
    "default": dict(
        ground=["#1E7360", "#175947", "#0A342B"],
        glow="#FFFFFF", glow_alpha=0.075,
        fill=["#FFFFFF", "#EEF4F1"],
        shadow="#04211B", shadow_alpha=0.05,
        track_alpha=0.13, hatch_alpha=0.075,
        groove_dark="#03201A", groove_dark_alpha=0.16, groove_light_alpha=0.08,
    ),
    "dark": dict(
        ground=["#14231C", "#0F1A16", "#060B09"],
        glow="#4EB08C", glow_alpha=0.06,
        fill=["#4EB08C", "#3F9C7A"],
        shadow="#000000", shadow_alpha=0.055,
        track_alpha=0.11, hatch_alpha=0.065,
        groove_dark="#000000", groove_dark_alpha=0.20, groove_light_alpha=0.06,
    ),
    "tinted": dict(
        ground=["#232323", "#181818", "#080808"],
        glow="#FFFFFF", glow_alpha=0.06,
        fill=["#FFFFFF", "#E9E9E9"],
        shadow="#000000", shadow_alpha=0.055,
        track_alpha=0.13, hatch_alpha=0.075,
        groove_dark="#000000", groove_dark_alpha=0.18, groove_light_alpha=0.07,
    ),
}


def capsule(x: float, y: float, width: float, height: float, **attrs) -> str:
    radius = height / 2
    extra = ' '.join(f'{key.replace("_", "-")}="{value}"' for key, value in attrs.items())
    return (f'<rect x="{x:.2f}" y="{y:.2f}" width="{width:.2f}" height="{height:.2f}" '
            f'rx="{radius:.2f}" ry="{radius:.2f}" {extra}/>')


def svg(variant: str) -> str:
    theme = VARIANTS[variant]
    top, mid, bottom = theme["ground"]
    fill_top, fill_bottom = theme["fill"]

    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{CANVAS}" height="{CANVAS}" '
        f'viewBox="0 0 {CANVAS} {CANVAS}">',
        '  <defs>',
        '    <linearGradient id="ground" x1="0" y1="0" x2="0.18" y2="1">',
        f'      <stop offset="0" stop-color="{top}"/>',
        f'      <stop offset="0.42" stop-color="{mid}"/>',
        f'      <stop offset="1" stop-color="{bottom}"/>',
        '    </linearGradient>',
        '    <radialGradient id="glow" cx="0.36" cy="0.20" r="0.72">',
        f'      <stop offset="0" stop-color="{theme["glow"]}" '
        f'stop-opacity="{theme["glow_alpha"]}"/>',
        f'      <stop offset="1" stop-color="{theme["glow"]}" stop-opacity="0"/>',
        '    </radialGradient>',
        '    <linearGradient id="groove" x1="0" y1="0" x2="0" y2="1">',
        f'      <stop offset="0" stop-color="{theme["groove_dark"]}" '
        f'stop-opacity="{theme["groove_dark_alpha"]}"/>',
        f'      <stop offset="0.5" stop-color="{theme["groove_dark"]}" stop-opacity="0"/>',
        f'      <stop offset="1" stop-color="#FFFFFF" '
        f'stop-opacity="{theme["groove_light_alpha"]}"/>',
        '    </linearGradient>',
        '    <linearGradient id="active" x1="0" y1="0" x2="0" y2="1">',
        f'      <stop offset="0" stop-color="{fill_top}"/>',
        f'      <stop offset="1" stop-color="{fill_bottom}"/>',
        '    </linearGradient>',
    ]

    for index in range(3):
        y = Y0 + index * (BAR_H + GAP)
        out.append(f'    <clipPath id="track{index}">')
        out.append('      ' + capsule(X0, y, TRACK_W, BAR_H))
        out.append('    </clipPath>')
    out.append('  </defs>')

    out.append(f'  <rect width="{CANVAS}" height="{CANVAS}" fill="url(#ground)"/>')
    out.append(f'  <rect width="{CANVAS}" height="{CANVAS}" fill="url(#glow)"/>')

    for index, fraction in enumerate(FRACTIONS):
        y = Y0 + index * (BAR_H + GAP)

        # La rainure : aplat translucide, hachures gravées, puis ombrage de creux.
        out.append(f'  <g clip-path="url(#track{index})">')
        out.append('    ' + capsule(X0, y, TRACK_W, BAR_H,
                                    fill="#FFFFFF", fill_opacity=theme["track_alpha"]))
        for x in range(int(X0 - BAR_H), int(X0 + TRACK_W + BAR_H), HATCH_STEP):
            out.append(f'    <line x1="{x}" y1="{y + BAR_H}" x2="{x + BAR_H}" y2="{y}" '
                       f'stroke="#FFFFFF" stroke-opacity="{theme["hatch_alpha"]}" '
                       f'stroke-width="{HATCH_W}"/>')
        out.append('    ' + capsule(X0, y, TRACK_W, BAR_H, fill="url(#groove)"))
        out.append('  </g>')

        width = max(BAR_H, TRACK_W * fraction)

        # Ombre douce : du plus large et plus pâle vers le plus serré.
        for layer in range(SHADOW_LAYERS, 0, -1):
            spread = layer * 1.1
            offset = layer * 1.7
            out.append('  ' + capsule(X0 - spread, y + offset,
                                      width + spread * 2, BAR_H,
                                      fill=theme["shadow"],
                                      fill_opacity=theme["shadow_alpha"]))

        out.append('  ' + capsule(X0, y, width, BAR_H, fill="url(#active)"))

    out.append('</svg>')
    return '\n'.join(out)


def render(variant: str, out: pathlib.Path, size: int = CANVAS) -> Image.Image:
    """Rasterise le SVG puis aplatit l'alpha : l'App Store refuse la transparence."""
    data = cairosvg.svg2png(bytestring=svg(variant).encode('utf-8'),
                            output_width=size, output_height=size)
    tmp = out.with_suffix('.rgba.png')
    tmp.write_bytes(data)
    image = Image.open(tmp).convert('RGBA')
    flat = Image.new('RGB', image.size, (0, 0, 0))
    flat.paste(image, mask=image.split()[3])
    flat.save(out, 'PNG', optimize=True)
    tmp.unlink()
    return flat


def squircle_mask(size: int, exponent: float = 5.0) -> Image.Image:
    """Masque en superellipse, forme des icônes iOS, calculé puis réduit."""
    supersample = 4
    dimension = size * supersample
    axis = np.linspace(-1, 1, dimension)
    grid_x, grid_y = np.meshgrid(axis, axis)
    inside = (np.abs(grid_x) ** exponent + np.abs(grid_y) ** exponent) <= 1
    return Image.fromarray((inside * 255).astype('uint8'), mode='L') \
                .resize((size, size), Image.LANCZOS)


def contact_sheet(source: Image.Image, out: pathlib.Path) -> None:
    """Planche de contrôle : l'icône masquée aux tailles réelles d'usage, sur
    fond clair et sur fond sombre. Seule façon de juger une icône avant
    de la voir sur un appareil."""
    sizes = [1024, 180, 120, 80, 60, 40]
    labels = ["1024 · App Store", "180 · accueil", "120 · Spotlight",
              "80 · réglages", "60", "40 · notification"]
    margin, gutter, label_h, preview = 64, 40, 34, 256
    row_h = preview + label_h + gutter
    width = margin * 2 + preview * len(sizes) + gutter * (len(sizes) - 1)
    height = margin * 2 + row_h * 2

    sheet = Image.new('RGB', (width, height), (244, 246, 245))
    draw = ImageDraw.Draw(sheet)
    draw.rectangle([0, margin + row_h - gutter // 2, width, height], fill=(13, 16, 15))

    for row, background in enumerate([(244, 246, 245), (13, 16, 15)]):
        ink = (23, 27, 25) if row == 0 else (241, 243, 241)
        for column, size in enumerate(sizes):
            icon = source.resize((size, size), Image.LANCZOS)
            icon.putalpha(squircle_mask(size))
            if size > preview:
                icon = icon.resize((preview, preview), Image.LANCZOS)
                icon.putalpha(squircle_mask(preview))
                offset = (0, 0)
            else:
                offset = ((preview - size) // 2, (preview - size) // 2)
            tile = Image.new('RGB', (preview, preview), background)
            tile.paste(icon, offset, icon)
            x = margin + column * (preview + gutter)
            y = margin + row * row_h
            sheet.paste(tile, (x, y))
            draw.text((x, y + preview + 10), labels[column], fill=ink)
    sheet.save(out, 'PNG', optimize=True)


if __name__ == '__main__':
    root = pathlib.Path(__file__).resolve().parent
    root.mkdir(parents=True, exist_ok=True)
    for name in VARIANTS:
        (root / f'Nutristack_AppIcon_{name}.svg').write_text(svg(name), encoding='utf-8')
    default = render('default', root / 'Nutristack_AppIcon_1024.png')
    render('dark', root / 'Nutristack_AppIcon_1024_dark.png')
    render('tinted', root / 'Nutristack_AppIcon_1024_tinted.png')
    contact_sheet(default, root / 'Nutristack_AppIcon_apercu.png')
    print('piste', TRACK_W, '· barre', BAR_H, '· rapport', TRACK_W / BAR_H)
    print('marges latérales', X0, f'({X0 / CANVAS:.1%})',
          '· marge haute', Y0, f'({Y0 / CANVAS:.1%})')
    print('fraction 12,5 % =', TRACK_W * 0.125, '= hauteur de barre, donc disque parfait')
    print('emprise du dessin :', f'{TRACK_W / CANVAS:.1%} × {TOTAL_H / CANVAS:.1%}')
