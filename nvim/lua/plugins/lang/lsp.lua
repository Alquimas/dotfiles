return {
    "neovim/nvim-lspconfig",
    enabled = config.nvim_lspconfig,
    lazy = false,
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
    },

    config = function()
        local signs = {
            Error = '✖',
            Warn = '',
            Hint = '',
            Info = '',
        }

        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        vim.diagnostic.config({
            virtual_text = false,
            underline = true,
            signs = true,
            severity_sort = true,
            float = {
                border = "rounded",
                source = "always",
                focusable = false,
            },
        })

--local lspconfig = require('lspconfig')
--local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP actions',
            callback = function(event)
                local opts = { buffer = event.buf }

                local map = utils.map

                local normal = {
                    ['K'] = {
                        '<cmd>lua vim.lsp.buf.hover()<cr>',
                        "Hover",
                        opts
                    },
                    ['gd'] = {
                        '<cmd>lua vim.lsp.buf.definition()<cr>',
                        "Ir para definição",
                        opts
                    },
                    ['gD'] = {
                        '<cmd>lua vim.lsp.buf.declaration()<cr>',
                        "Ir para declaração",
                        opts
                    },
                    ['gi'] = {
                        '<cmd>lua vim.lsp.buf.implementation()<cr>',
                        "Ir para implementação",
                        opts
                    },
                    ['go'] = {
                        '<cmd>lua vim.lsp.buf.type_definition()<cr>',
                        "Ir para definição de tipo",
                        opts
                    },
                    ['gr'] = {
                        '<cmd>lua vim.lsp.buf.references()<cr>',
                        "Ir para referencias",
                        opts
                    },
                    ['gs'] = {
                        '<cmd>lua vim.lsp.buf.signature_help()<cr>',
                        "Ver assinatura",
                        opts
                    },
                    ['<F2>'] = {
                        '<cmd>lua vim.lsp.buf.rename()<cr>',
                        "Renomear",
                        opts
                    },
                    ['<F3>'] = {
                        '<cmd>lua vim.lsp.buf.format({async = true})<cr>',
                        "Formatar",
                        opts
                    },
                    ['<F4>'] = {
                        '<cmd>lua vim.lsp.buf.code_action()<cr>',
                        "Code action",
                        opts
                    },
                    ['<leader>l'] = {
                        '<cmd>lua vim.diagnostic.open_float()<cr>',
                        "Abrir diagnostico",
                        opts
                    },
                    ['[d'] = {
                        '<cmd>lua vim.diagnostic.goto_prev()<cr>',
                        "Ir para próximo diagnostico",
                        opts
                    },
                    [']d'] = {
                        '<cmd>lua vim.diagnostic.goto_next()<cr>',
                        "Ir para diagnostico anterior",
                        opts
                    },
                }
                local insert = {
                    ['gs'] = {
                        '<cmd>lua vim.lsp.buf.signature_help()<cr>',
                        "Ver assinatura",
                        opts
                    },
                }
                map("n", normal)
                map("i", insert)
            end
        })

        for k, v in pairs(config.servers) do
            assert(loadstring('return ' ..
                string.format("require('lspconfig').%s.setup", k) ..
                '(...)'))(v)
        end
    end,
}
