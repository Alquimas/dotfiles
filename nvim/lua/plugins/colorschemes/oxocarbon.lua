local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local hl = vim.api.nvim_set_hl

return {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    config = function()
        local colorscheme = augroup("ColorScheme", { clear = true })
        autocmd("ColorScheme", {
            group = colorscheme,
            pattern = "*",
            callback = function()
                hl(0, "DiagnosticWarn", { fg = '#ffee00', bg = '#161616' })
                hl(0, "DiagnosticError", { fg = '#ff0015', bg = '#161616' })
                hl(0, "DiagnosticInfo", { fg = '#3094ff', bg = '#161616' })
                hl(0, "DiagnosticHint", { fg = '#00ff11', bg = '#161616' })
                hl(0, "DiagnosticUnderlineWarn",
                    { fg = '#ffee00', bg = '#161616', undercurl = true })
                hl(0, "DiagnosticUnderlineError",
                    { fg = '#ff0015', bg = '#161616', undercurl = true })
                hl(0, "DiagnosticUnderlineInfo",
                    { fg = '#3094ff', bg = '#161616', undercurl = true })
                hl(0, "DiagnosticUnderlineHint",
                    { fg = '#00ff11', bg = '#161616', undercurl = true })
                hl(0, "SignColumn", { fg = '#00685B', bg = '#161616' })
                hl(0, "FoldColumn", { fg = '#78a9ff', bg = '#161616' })
                hl(0, "Folded", { fg = '#393935', bg = '#161616', italic = true })
            end,
        })
    end
}
