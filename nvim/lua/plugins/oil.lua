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

    keys = {
        {
            "<leader>x",
            "<cmd>Oil<CR>",
            {desc = "Open parent directory in Oil"}
        }
    },
}
