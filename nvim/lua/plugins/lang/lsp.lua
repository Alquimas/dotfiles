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
            inlay_hints = {
                enabled = true,
            },
        })

--local lspconfig = require('lspconfig')
--local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP actions',
            callback = function(event)
                local opts = { buffer = event.buf }

                local map = Utils.map

                local normal = {
                    ['<leader>cK'] = {
                        '<cmd>lua vim.lsp.buf.hover()<cr>',
                        "Displays hover information about the symbol under the\
                        cursor.",
                        opts
                    },
                    ['<leader>cd'] = {
                        '<cmd>lua vim.lsp.buf.definition()<cr>',
                        "Jumps to the definition of the symbol\
                        under the cursor.",
                        opts
                    },
                    ['<leader>cD'] = {
                        '<cmd>lua vim.lsp.buf.declaration()<cr>',
                        "Jumps to the declaration of the symbol\
                        under the cursor.",
                        opts
                    },
                    ['<leader>ci'] = {
                        '<cmd>lua vim.lsp.buf.implementation()<cr>',
                        "Lists all the implementations for the symbol\
                        under the cursor in the quickfix window.",
                        opts
                    },
                    ['<leader>cy'] = {
                        '<cmd>lua vim.lsp.buf.type_definition()<cr>',
                        "Jumps to the definition of the type of the symbol\
                        under the cursor.",
                        opts
                    },
                    ['<leader>cR'] = {
                        '<cmd>lua vim.lsp.buf.references()<cr>',
                        "Lists all the references to the symbol\
                        under the cursos in the quickfix window.",
                        opts
                    },
                    ['<leader>ck'] = {
                        '<cmd>lua vim.lsp.buf.signature_help()<cr>',
                        "Displays signature information about the symbol under\
                        the cursor in a floating window.",
                        opts
                    },
                    ['<leader>cr'] = {
                        '<cmd>lua vim.lsp.buf.rename()<cr>',
                        "Renames all references to the symbol under the\
                        cursor.",
                        opts
                    },
                    ['<leader>cf'] = {
                        '<cmd>lua vim.lsp.buf.format({async = true})<cr>',
                        "Formats a buffer using the attached language server\
                        clients.",
                        opts
                    },
                    ['<leader>ca'] = {
                        '<cmd>lua vim.lsp.buf.code_action()<cr>',
                        "Selects a code action available at the current cursor\
                        position.",
                        opts
                    },
                    ['<leader>cc'] = {
                        '<cmd>lua vim.diagnostic.open_float()<cr>',
                        "Show diagnostics in a floating window.",
                        opts
                    },
                    ['<leader>cq'] = {
                        '<cmd>lua vim.diagnostic.setqflist()<cr>',
                        "Add all diagnostics to the quickfix list.",
                        opts
                    },
                    ['<leader>c['] = {
                        '<cmd>lua vim.diagnostic.goto_prev()<cr>',
                        "Move to the previous diagnostic in the current\
                        buffer.",
                        opts
                    },
                    ['<leader>c]'] = {
                        '<cmd>lua vim.diagnostic.goto_next()<cr>',
                        "Move to the next diagnostic in the current\
                        buffer.",
                        opts
                    },
                }
                map("n", normal)
            end
        })

        for k, v in pairs(config.servers) do
            assert(loadstring('return ' ..
                string.format("require('lspconfig').%s.setup", k) ..
                '(...)'))(v)
        end

        local wk = require("which-key")
        wk.add({
            {"<leader>c", group = "LSP"},
        })
    end,
}
