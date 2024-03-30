return {
    'navarasu/onedark.nvim',
    lazy = false,
    config = function()
        local onedark = require('onedark')
        local opts = {
            style = 'warmer',
            transparent = false,
            term_colors = true,
            ending_tildes = false,
            cmp_itemkind_reverse = false,

            toggle_style_key = '<leader>cs',
            toggle_style_list = {
                                  'dark',
                                  'darker',
                                  'cool',
                                  'deep',
                                  'warm',
                                  'warmer',
                                  'light'
                                },

            code_style = {
                comments = 'italic',
                keywords = 'none',
                functions = 'none',
                strings = 'none',
                variables = 'none'
            },

            lualine = {
                transparent = false,
            },

            colors = {},
            highlights = {},

            diagnostics = {
                darker = true,
                undercurl = true,
                background = true,
            },
        }
        onedark.setup(opts)
    end
}
