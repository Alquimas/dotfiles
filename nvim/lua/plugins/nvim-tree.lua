return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    enabled = config.nvim_tree,
    cmd = { "NvimTreeToggle" },
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    config = function() -- {{{
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        local nvtree = require("nvim-tree")
        local api = require("nvim-tree.api")

        local function attach(bufnr)
            -- This will make sure that newly created file get's open to edit
            api.events.subscribe(api.events.Event.FileCreated, function(file)
                vim.cmd("edit " .. file.fname)
            end)

            -- functions used to map
            local function opts(desc)
                return {
                    desc = "nvim-tree: " .. desc,
                    buffer = bufnr,
                    noremap = true,
                    silent = true,
                    nowait = true,
                }
            end

            local function set(mode, data)
                for key, value in pairs(data) do
                    vim.keymap.set(mode, key, value[1], value[2])
                end
            end

            local normal = {
                ["?"] = { api.tree.toggle_help, opts("Help") },
            }

            api.config.mappings.default_on_attach(bufnr)
            set("n", normal)

            vim.keymap.set("n", "P", function() -- Special fn to print node PATH
                local node = api.tree.get_node_under_cursor()
                print(node.absolute_path)
            end, opts("Print Node Path"))
        end

        local opts = {
            on_attach = attach,
            disable_netrw = true,
            hijack_netrw = true,
            hijack_cursor = true,
            hijack_unnamed_buffer_when_opening = false,
            sync_root_with_cwd = true,
            update_focused_file = {
                enable = true,
                update_root = true,
            },
            view = {
                number = false,
                relativenumber = false,
                signcolumn = "no",
                width = 30,
            },
            renderer = {
                root_folder_label = ":~:s?$?/..?",
                --identação dos arquivos
                indent_markers = {
                    enable = true,
                    icons = {
                        corner = "└ ",
                        edge = "│ ",
                        item = "│ ",
                        none = "  ",
                    },
                },
                --iconezinho kekw
                icons = {
                    webdev_colors = true,
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true
                    },
                    glyphs = {
                        default = "",
                        symlink = "",
                        folder = {
                            arrow_closed = "",
                            arrow_open = "",
                            default = "",
                            open = "",
                            empty = "",
                            empty_open = "",
                            symlink = "",
                            symlink_open = "",
                        },
                        git = {
                            unstaged = "", -- 
                            staged = "",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "",
                            deleted = "",
                            ignored = "◌",
                        },
                    },
                }
            },
            filters = {
                dotfiles = true,
                git_clean = false,
                no_buffer = false,
                custom = {},
                exclude = {},
            },
        }
        nvtree.setup(opts)
    end, -- }}}
    keys = {
        { "<leader>x", "<cmd>NvimTreeToggle<cr>", desc = "Nvim Tree" },
    },
}
