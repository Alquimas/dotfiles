return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    config = function()
        local lualine = require("lualine")

        local opts = {
            options = {
                icons_enabled = true,
                theme = 'onedark',
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                    statusline = { "neo-tree", "NvimTree", "undotree", "diff", "oil" },
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = true,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff',
                    {
                        "diagnostics",
                        symbols = {
                            error = '✖ ',
                            warn = ' ',
                            hint = ' ',
                            info = ' ',
                        },
                        always_visible = true,
                        colored = true,
                    },
                },
                lualine_c = {},
                lualine_x = {
                    {
                        "filetype",
                        icon_only = true,
                        separator = "",
                        padding = { left = 1, right = 0 }
                    },
                    {
                        "filename",
                        file_status = true,
                        path = 1,
                        symbols = {
                            modified = '{+}',
                            readonly = '{-}',
                            unnamed = '{No Name}',
                            newfile = '{New}',
                        }
                    },
                },
                lualine_y = { 'progress' },
                lualine_z = { 'location' }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {}
            },
        }
        lualine.setup(opts)
    end,
}
