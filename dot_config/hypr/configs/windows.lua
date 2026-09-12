-- Migrated from windows.conf
-- Window rules now require a `name` field (hyprlang rules were anonymous).

hl.window_rule({
    name  = "float-firefox-sharing-indicator",
    match = { title = "^(Firefox — Sharing Indicator)$" },

    float = true,
})
