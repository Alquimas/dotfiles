return {
    'mbbill/undotree',
    lazy = false,
    enabled = config.undotree,
    config = function()
        vim.keymap.set('n',
            '<C- >',
            vim.cmd.UndotreeToggle,
            { desc = "Undo Tree" }
        )
        ----------------- Opções
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_RelativeTimestamp = 1
        vim.g.undotree_ShortIndicators = 1
        vim.g.undotree_SplitWidth = 24
        vim.g.undotree_DiffpanelHeight = 4
    end,
}
