return {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    lazy = false,
    opts = {
        disabled_filetypes = { "qf", "netrw", "lazy", "mason", "oil"},
    }
}
