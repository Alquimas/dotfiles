return {
    'tpope/vim-fugitive',
    lazy = false,
    enabled = config.vim_fugitive,
    vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git Status" })
}
