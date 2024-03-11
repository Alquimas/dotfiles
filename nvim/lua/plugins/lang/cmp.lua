return {
    "hrsh7th/nvim-cmp",
    enabled = config.nvim_cmp,
    lazy = false,
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
    },
    config = function()
        local cmp = require("cmp")

        local default_cmp_sources = {
            { name = 'nvim_lsp' },
        }
        local mappings = {
            ['<TAB>'] = cmp.mapping.confirm({ select = false }),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<Up>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
            ['<Down>'] = cmp.mapping.select_next_item({ behavior = 'select' }),
            ['<C-p>'] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = 'insert' })
                else
                    cmp.complete()
                end
            end),
            ['<C-n>'] = cmp.mapping(function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = 'insert' })
                else
                    cmp.complete()
                end
            end),
        }
        local opts = {
            completion = {
                completeopt = 'menu,menuone',
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            window = {
                completion = {
                    scrollbar = false,
                    border = "rounded",
                },
                documentation = {
                    border = "rounded",
                },
            },
            sources = default_cmp_sources,
            mapping = mappings,
        }

        cmp.setup(opts)
    end,
}
