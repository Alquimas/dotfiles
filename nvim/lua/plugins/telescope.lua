return {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.5',
    enabled = config.telescope,
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        },
    },

    config = function()
        local telescope = require("telescope")

        local opts = {
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
            defaults = {
                previewer = false,
                layout_strategy = 'horizontal',
                sorting_strategy = 'ascending',
                layout_config = {
                    horizontal = {
                        anchor = 'center',
                        height = 0.9,
                        preview_cutoff = 120,
                        preview_width = 50,
                        prompt_position = 'bottom',
                        width = 0.9,
                    },
                },
                prompt_prefix = ' ',
                selection_caret = ' ',
                border = true,
                borderchars = {
                    prompt = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' },
                    results = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' },
                    preview = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' },
                },
            },
        }
        telescope.setup(opts)

        local ext = {
            "fzf",
        }

        -- load extensions
        for _, extension in ipairs(ext) do
            telescope.load_extension(extension)
        end

        local wk = require("which-key")
        wk.add({
            { "<leader>f", group = "Telescope"},
        })

    end,

    keys = {
        {
            "<leader>ff",
            "<cmd>Telescope find_files<cr>",
            desc = "Find Files"
        },
        {
            "<leader>fg",
            "<cmd>Telescope git_files<cr>",
            desc = "Git Files"
        },
        {
            "<leader>fb",
            "<cmd>Telescope buffers<cr>",
            desc = "See Buffers"
        },
        {
            "<leader>fo",
            "<cmd>Telescope oldfiles<cr>",
            desc = "Old Files"
        },
        {
            "<leader>fc",
            "<cmd>Telescope current_buffer_fuzzy_find<cr>",
            desc = "Find in file",
        },
        {
            "<leader>fl",
            "<cmd>Telescope live_grep<cr>",
            desc = "Live grep"
        },
        {
            "<leader>fz",
            "<cmd>Telescope<cr>",
            desc = "Telescope"
        }
    },
}
