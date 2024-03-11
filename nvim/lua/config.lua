M = {}

local servers = {}

servers.rust_analyzer = {}

servers.clangd = {}

servers.lua_ls = {
    Lua = {
        diagnostics = {
            globals = { "vim", "config", "utils", "icons" },
            disable = {
                "lowercase-global",
            },
        },
    },
}

servers.hls = {}

--[[servers.ltex = {
    language = { "en-US", "pt-BR" },
}]]
--

servers.texlab = {}

servers.jdtls = {}

servers.ocamllsp = {}

servers.elixirls = {
    cmd = { vim.fn.expand("$HOME") ..
    "/.config/nvim/language_servers/elixir-ls-v0.17.8/language_server.sh" },
}

servers.zls = {}

servers.asm_lsp = {
    cmd = { "asm-lsp" },
    root_dir =
        function(fname)
            return vim.fn.getcwd()
        end,
}

M.servers = servers

return M
