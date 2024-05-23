return {
    "nvim-treesitter/nvim-treesitter",
    enabled = config.nvim_treesitter,
    lazy = false,
    build = ":TSUpdate",

    opts = {
        ensure_installed = {
            "lua",
            "c",
            "vim",
            "vimdoc",
            "query",
            "java",
            "haskell",
            "elixir",
            "markdown",
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<Enter>",
                node_incremental = "<Enter>",
                node_decremental = "<BS>",
            },
        },
        auto_install = true,
        highlight = {
            enable = true,
        },
        indent = {
            enable = false,
        }
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
}
