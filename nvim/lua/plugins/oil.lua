return {
    'stevearc/oil.nvim',
    opts = {},
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local opts = {
            columns = {
                "icon",
                -- "permissions",
                -- "size",
                -- "mtime",
            },
        }
        require("oil").setup(opts)
    end,
    vim.keymap.set(
        "n",
        "<leader>x",
        "<CMD>Oil --float<CR>",
        {desc = "Open parent directory" }
    )
}
