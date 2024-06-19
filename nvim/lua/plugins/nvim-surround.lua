return {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            keymaps = {
                insert = "<C-g>sa",
                insert_line = "<C-g>Sa",
                normal = "gsa",
                normal_cur = "gsaa",
                normal_line = "gsA",
                normal_cur_line = "gsAA",
                visual = "gsa",
                visual_line = "gsA",
                delete = "gsd",
                change = "gsc",
                change_line = "gsC",
            },
        })
    end
}
