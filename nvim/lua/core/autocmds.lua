local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Destaca conteudo copiado
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
    group = highlight_group,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 500 }
    end,
})

-- Ao salvar um arquivo, deleta qualquer espaço sobrando
local remove_trailing_space = augroup("TrailingSpace", {})
autocmd({ "BufWritePre" }, {
    group = remove_trailing_space,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- volta o cursor para a posicao que estava antes de :q
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

-- ao entrar no modo de insercao, desabilita o relativenumber
local togglegroup = augroup("NumberToggle", { clear = true })
autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
    group = togglegroup,
    desc = "When enter insert mode, disables relativenumber",
    pattern = "*",
    callback = function()
        vim.wo.relativenumber = true
    end,
})

autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
    group = togglegroup,
    desc = "When leaves insert mode, enables relativenumber",
    pattern = "*",
    callback = function()
        vim.wo.relativenumber = false
    end,
})

local startup = augroup("Startup", {})
autocmd({ "VimEnter" }, {
    group = startup,
    desc = "When entering vim, open nvimtree",
    pattern = "*",
    callback = function ()
        require("nvim-tree.api").tree.open()
    end,
})

--[[
local get_indent = augroup("GetIndent", {clear = true})
autocmd("BufReadPre", {
    group = get_indent,
    pattern = "*",
    callback = function ()
        vim.opt_local.foldmethod = "indent"
    end,
})

autocmd("BufWinEnter", {
    group = get_indent,
    pattern = "*",
    callback = function ()
        vim.opt_local.foldmethod = "manual"
    end,
})]]--
