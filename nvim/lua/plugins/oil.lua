return {
    'stevearc/oil.nvim',
    opts = {},
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({})
    end,
    vim.keymap.set("n", "<leader>x", "<CMD>Oil<CR>", { desc = "Open parent directory" })
}
