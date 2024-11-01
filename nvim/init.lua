Utils = require("core.utils")

require("core")

cok, config = pcall(require, "config")
if not cok then
    config = {}
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.filetype = on

local opts = {
    ui = {
        border = "rounded",
        icons = {
            ft = "",
            lazy = "󰂠 ",
            loaded = "",
            not_loaded = "",
        },
    },
    change_detection = { enabled = false },
    defaults = {
        lazy = true,
    },
    install = {
        colorscheme = {
            "catppuccin/nvim",
        },
    },
}

require("lazy").setup("plugins", opts)

vim.cmd("colorscheme catppuccin-mocha")
