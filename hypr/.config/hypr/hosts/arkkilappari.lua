-- Laptop: HP EliteBook 850 G6

-- Internal display
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1.25
})

-- Any other (external) monitor: auto-placed next to the laptop
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1
})
