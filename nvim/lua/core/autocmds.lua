local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- highlights yanked content
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
    group = highlight_group,
    desc = "Highlight yank content",
    pattern = "*",
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 500 }
    end,
})

-- restores cursor position in file when reopening it
local restorecursor = augroup("RestoreCursor", {})
autocmd("BufReadPost", {
    group = restorecursor,
    desc = "Restore last cursor position in file",
    callback = function()
        if vim.fn.line("'\"") > 0 and
            vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.fn.setpos(".", vim.fn.getpos("'\""))
        end
    end,
})

-- when entering insert mode, disables the relativenumber
local togglegroup = augroup("NumberToggle", { clear = true })
autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
    group = togglegroup,
    desc = "When enter insert mode, disables relativenumber",
    pattern = "*",
    callback = function()
        vim.wo.relativenumber = true
    end,
})

-- when leaving insert mode, enables the relativenumber
autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
    group = togglegroup,
    desc = "When leaves insert mode, enables relativenumber",
    pattern = "*",
    callback = function()
        vim.wo.relativenumber = false
    end,
})
