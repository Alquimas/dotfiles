return {
    'stevearc/oil.nvim',
    opts = {},
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local opts = {
            use_default_keymaps = false,
            columns = {
                "icon",
                -- "permissions",
                -- "size",
                -- "mtime",
            },
            keymaps = {
                ["<leader>x"] = "actions.close",
                ["<leader>xx"] = {
                    desc = "Toggle file detail view",
                    callback = function ()
                        Detail = not Detail
                        if Detail then
                            require("oil").set_columns({
                                "permissions",
                                "size",
                                "mtime"
                            })
                        else
                            require("oil").set_columns({
                                "icon"
                            })
                        end
                    end
                },
                ["<leader>x?"] = {
                    "actions.show_help",
                    desc = "Show help menu"
                },
                ["<CR>"] = "actions.select",
                ["<leader>xv"] = {
                    "actions.select",
                    opts = {
                        vertical = true
                    },
                    desc = "Open the entry in a vertical split"
                },
                ["<leader>xh"] = {
                    "actions.select",
                    opts = {
                        horizontal = true
                    },
                    desc = "Open the entry in a horizontal split"
                },
                ["<leader>xt"] = {
                    "actions.select",
                    opts = {
                        tab = true
                    },
                    desc = "Open the entry in new tab"
                },
                ["<leader>xp"] = {
                    "actions.preview",
                    desc = "Toggle preview mode"
                },
                ["<leader>xc"] = {
                    "actions.close",
                    desc = "Close Oil buffer"
                },
                ["<leader>xl"] = {
                    "actions.refresh",
                    desc = "Refresh Oil buffer"
                },
                ["<leader>x-"] = {
                    "actions.parent",
                    desc = "Open parent directory"
                },
                ["<leader>x_"] = {
                    "actions.open_cwd",
                    desc = "Open current working directory"
                },
                ["<leader>xd"] = {
                    "actions.cd",
                    desc = "Change cwd to the current Oil directory"
                },
                ["<leader>x~"] = {
                    "actions.cd",
                    opts = {
                        scope = "tab"
                    },
                    desc = ":tcd to the current oil directory"
                },
                ["<leader>xs"] = {
                    "actions.change_sort",
                    desc = "Change sorting strategy"
                },
                ["<leader>xe"] = "actions.open_external",
                ["<leader>x."] = {
                    "actions.toggle_hidden",
                    desc = "Toggle hidden files"
                },
                ["<leader>x\\"] = "actions.toggle_trash",
            },
        }
        require("oil").setup(opts)
    end,

    keys = {
        {
            "<leader>x",
            "<cmd>Oil<CR>",
            {
                desc = "Open parent directory in Oil"
            }
        },
    },
}
