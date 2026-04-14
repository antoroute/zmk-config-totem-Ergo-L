$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$imagesDir = Join-Path $repoRoot "docs\images"
$baseSvgPath = Join-Path $imagesDir "TOTEM_layout.svg"
$baseSvg = Get-Content -Raw $baseSvgPath

$rectPattern = '<rect class="cls-2" x="(?<x>[^"]+)" y="(?<y>[^"]+)" width="(?<w>38\.27|35\.43)" height="(?<h>35\.43|38\.27)" rx="\.95" ry="\.95"(?<transform> transform="[^"]+")?\/>'
$rectMatches = [regex]::Matches($baseSvg, $rectPattern)

if ($rectMatches.Count -ne 38) {
    throw "Expected 38 inner key rectangles, found $($rectMatches.Count)."
}

$culture = [System.Globalization.CultureInfo]::InvariantCulture
$rects = foreach ($match in $rectMatches) {
    [pscustomobject]@{
        X = [double]::Parse($match.Groups["x"].Value, $culture)
        Y = [double]::Parse($match.Groups["y"].Value, $culture)
        W = [double]::Parse($match.Groups["w"].Value, $culture)
        H = [double]::Parse($match.Groups["h"].Value, $culture)
        Transform = $match.Groups["transform"].Value
    }
}

function New-Line {
    param(
        [string]$Text,
        [string]$Tone = "tap"
    )

    [pscustomobject]@{
        Text = $Text
        Tone = $Tone
    }
}

function One {
    param(
        [string]$Text,
        [string]$Tone = "tap"
    )

    [pscustomobject]@{
        Lines = @((New-Line -Text $Text -Tone $Tone))
    }
}

function Dual {
    param(
        [string]$Tap,
        [string]$Hold
    )

    [pscustomobject]@{
        Lines = @(
            (New-Line -Text $Tap -Tone "tap")
            (New-Line -Text $Hold -Tone "hold")
        )
    }
}

function Stack {
    param(
        [string[]]$Text
    )

    [pscustomobject]@{
        Lines = @(
            $Text | ForEach-Object {
                New-Line -Text $_ -Tone "tap"
            }
        )
    }
}

function Set-RectLabels {
    param(
        [object[]]$VisualOrderLabels
    )

    $visualToRect = @(
        13, 10, 6, 3, 0, 19, 22, 25, 29, 32,
        14, 11, 7, 4, 1, 20, 23, 26, 30, 33,
        18, 15, 12, 8, 5, 2, 21, 24, 27, 31, 34, 37,
        9, 16, 17, 36, 35, 28
    )

    if ($VisualOrderLabels.Count -ne $visualToRect.Count) {
        throw "Expected $($visualToRect.Count) labels in visual order, found $($VisualOrderLabels.Count)."
    }

    $rectLabels = New-Object object[] 38
    for ($i = 0; $i -lt $visualToRect.Count; $i++) {
        $rectLabels[$visualToRect[$i]] = $VisualOrderLabels[$i]
    }

    return $rectLabels
}

function Get-SingleFontSize {
    param([string]$Text)

    switch ($Text.Length) {
        { $_ -le 2 } { return 13.5 }
        { $_ -le 4 } { return 11.0 }
        { $_ -le 6 } { return 9.2 }
        default { return 8.0 }
    }
}

function Get-KeyOverlay {
    param(
        [pscustomobject]$Rect,
        [pscustomobject]$Item,
        [double]$FillOpacity
    )

    if ($null -eq $Item) {
        return ""
    }

    $transform = if ([string]::IsNullOrWhiteSpace($Rect.Transform)) { "" } else { $Rect.Transform }
    $centerX = $Rect.X + ($Rect.W / 2.0)
    $centerY = $Rect.Y + ($Rect.H / 2.0) + 0.5

    $fill = '<rect x="{0}" y="{1}" width="{2}" height="{3}" rx=".95" ry=".95"{4} fill="#58a6ff" fill-opacity="{5}" stroke="none"/>' -f `
        ([string]::Format($culture, "{0:0.##}", $Rect.X)),
        ([string]::Format($culture, "{0:0.##}", $Rect.Y)),
        ([string]::Format($culture, "{0:0.##}", $Rect.W)),
        ([string]::Format($culture, "{0:0.##}", $Rect.H)),
        $transform,
        ([string]::Format($culture, "{0:0.##}", $FillOpacity))

    $textParts = @()
    $lines = $Item.Lines

    if ($lines.Count -eq 1) {
        $line = $lines[0]
        $fillColor = if ($line.Tone -eq "hold") { "#58a6ff" } else { "#f0f6fc" }
        $fontSize = Get-SingleFontSize -Text $line.Text
        $textParts += '<text x="{0}" y="{1}"{2} fill="{3}" font-family="''DejaVu Sans Mono'', ''SFMono-Regular'', Consolas, monospace" font-size="{4}" font-weight="700" text-anchor="middle" dominant-baseline="middle" stroke="#0d1117" stroke-width=".8" paint-order="stroke fill">{5}</text>' -f `
            ([string]::Format($culture, "{0:0.##}", $centerX)),
            ([string]::Format($culture, "{0:0.##}", $centerY)),
            $transform,
            $fillColor,
            ([string]::Format($culture, "{0:0.##}", $fontSize)),
            [System.Security.SecurityElement]::Escape($line.Text)
    } else {
        $isDualRole = ($lines.Count -eq 2) -and ($lines[0].Tone -eq "tap") -and ($lines[1].Tone -eq "hold")
        $gap = if ($isDualRole) { 10.5 } else { 9.5 }
        $topOffset = -($gap * ($lines.Count - 1) / 2.0)

        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            $fillColor = if ($line.Tone -eq "hold") { "#58a6ff" } else { "#f0f6fc" }
            $fontSize = if ($isDualRole) {
                if ($line.Tone -eq "hold") { 7.0 } else { 11.0 }
            } else {
                8.8
            }

            $lineY = $centerY + $topOffset + ($gap * $i)
            $textParts += '<text x="{0}" y="{1}"{2} fill="{3}" font-family="''DejaVu Sans Mono'', ''SFMono-Regular'', Consolas, monospace" font-size="{4}" font-weight="700" text-anchor="middle" dominant-baseline="middle" stroke="#0d1117" stroke-width=".8" paint-order="stroke fill">{5}</text>' -f `
                ([string]::Format($culture, "{0:0.##}", $centerX)),
                ([string]::Format($culture, "{0:0.##}", $lineY)),
                $transform,
                $fillColor,
                ([string]::Format($culture, "{0:0.##}", $fontSize)),
                [System.Security.SecurityElement]::Escape($line.Text)
        }
    }

    return @($fill) + $textParts -join "`n    "
}

function Write-LayerSvg {
    param(
        [string]$Name,
        [object[]]$Labels,
        [double]$FillOpacity = 0.16
    )

    $overlayParts = @()
    for ($i = 0; $i -lt $rects.Count; $i++) {
        $overlay = Get-KeyOverlay -Rect $rects[$i] -Item $Labels[$i] -FillOpacity $FillOpacity
        if (-not [string]::IsNullOrWhiteSpace($overlay)) {
            $overlayParts += $overlay
        }
    }

    $legend = @'
  <g id="Readme_Legend">
    <rect x="250.5" y="237.2" width="231.8" height="19.2" rx="9.6" ry="9.6" fill="#0d1117" fill-opacity=".82" stroke="#58a6ff" stroke-opacity=".28" stroke-width=".6"/>
    <text x="272.5" y="246.8" fill="#f0f6fc" font-family="'DejaVu Sans Mono', 'SFMono-Regular', Consolas, monospace" font-size="9" font-weight="700">tap</text>
    <text x="297.8" y="246.8" fill="#8b949e" font-family="'DejaVu Sans Mono', 'SFMono-Regular', Consolas, monospace" font-size="9">= label principal</text>
    <text x="385.9" y="246.8" fill="#58a6ff" font-family="'DejaVu Sans Mono', 'SFMono-Regular', Consolas, monospace" font-size="9" font-weight="700">hold</text>
    <text x="417.5" y="246.8" fill="#8b949e" font-family="'DejaVu Sans Mono', 'SFMono-Regular', Consolas, monospace" font-size="9">= action maintenue</text>
  </g>
'@

    $overlayGroup = @"
  <g id="Readme_Overlay_$Name">
    $($overlayParts -join "`n    ")
  </g>
$legend
"@

    $outSvg = $baseSvg -replace '</svg>\s*$', "$overlayGroup</svg>"
    $outPath = Join-Path $imagesDir "TOTEM_layer_$Name.svg"
    Set-Content -Path $outPath -Value $outSvg -Encoding utf8
}

$baseLabels = Set-RectLabels -VisualOrderLabels @(
    (One "Q"), (One "C"), (One "O"), (One "P"), (One "W"), (One "J"), (One "M"), (One "D"), (One "'"), (One "Y"),
    (Dual "A" "GUI"), (Dual "S" "ALT"), (Dual "E" "SFT"), (Dual "N" "CTL"), (One "F"), (One "L"), (Dual "R" "CTL"), (Dual "T" "SFT"), (Dual "I" "ALT"), (Dual "U" "GUI"),
    (One "SYS" "hold"), (One "ESC"), (One "Z"), (One "X"), (One "-"), (One "V"), (One "B"), (One "H"), (One "G"), (One ","), (One "."), (One "K"),
    (One "TAB"), (Dual "BSPC" "NAV"), (One "SPACE"), (One "ENTER"), (Dual "DEL" "SYM"), (One "AltGr" "hold")
)

$navLabels = Set-RectLabels -VisualOrderLabels @(
    (One "1"), (One "2"), (One "3"), (One "4"), (One "5"), (One "6"), (One "7"), (One "8"), (One "9"), (One "0"),
    (One "TAB"), (One "HOME"), (One "PGDN"), (One "PGUP"), (One "END"), (One "LEFT"), (One "DOWN"), (One "UP"), (One "RGHT"), (One "DEL"),
    (One "SYS" "hold"), (One "CTRL"), (One "SHIFT"), $null, $null, $null, $null, $null, $null, $null, $null, $null,
    $null, $null, $null, $null, $null, $null
)

$symLabels = Set-RectLabels -VisualOrderLabels @(
    (One "!"), (One "@"), (One "#"), (One "$"), (One "%"), (One "^"), (One "&"), (One "*"), (One "="), (One "+"),
    (One "("), (One "["), (One "{"), (One '`'), (One "'"), (One "-"), (One "}"), (One "]"), (One ")"), (One '"'),
    (One "SYS" "hold"), $null, (One '\'), (One "/"), (One ","), (One "."), (One ";"), (One "'"), (Stack @("C", "CED")), (Stack @("E", "ACU")), (Stack @("A", "GRA")), (Stack @("E", "GRA")),
    $null, $null, $null, $null, $null, $null
)

$sysLabels = Set-RectLabels -VisualOrderLabels @(
    (Stack @("BT", "0")), (Stack @("BT", "1")), (Stack @("BT", "2")), (Stack @("BT", "3")), (Stack @("BT", "CLR")),
    $null, $null, $null, $null, $null,
    (One "BOOT"), (One "RESET"), (Stack @("OUT", "TOG")), $null, $null,
    $null, $null, $null, $null, $null,
    $null, $null, $null, $null, $null, $null, $null, $null, $null, $null, $null, $null,
    $null, $null, $null, $null, $null, $null
)

$gameLabels = Set-RectLabels -VisualOrderLabels @(
    (One "ESC"), (One "Q"), (One "W"), (One "E"), (One "R"), (One "Y"), (One "U"), (One "I"), (One "O"), (One "P"),
    (One "TAB"), (One "A"), (One "S"), (One "D"), (One "F"), (One "H"), (One "J"), (One "K"), (One "L"), (One ";"),
    (One "SYS" "hold"), (One "SFT"), (One "Z"), (One "X"), (One "C"), (One "V"), (One "B"), (One "N"), (One "M"), (One ","), (One "."), (One "/"),
    (One "SFT"), (One "SPACE"), (One "LCTL"), (One "SPACE"), (One "SPACE"), (One "ENTER")
)

Write-LayerSvg -Name "base" -Labels $baseLabels -FillOpacity 0.14
Write-LayerSvg -Name "nav" -Labels $navLabels -FillOpacity 0.18
Write-LayerSvg -Name "sym" -Labels $symLabels -FillOpacity 0.18
Write-LayerSvg -Name "sys" -Labels $sysLabels -FillOpacity 0.18
Write-LayerSvg -Name "game" -Labels $gameLabels -FillOpacity 0.16
