M = {}

local servers = {}

servers.rust_analyzer = {}

servers.clangd = {
    cmd = {
        "clangd",
        "--clang-tidy",
        "--clang-tidy-checks=*",
    }
}

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

servers.texlab = {}

servers.jdtls = {}

servers.ocamllsp = {}

servers.zls = {}

servers.asm_lsp = {
    cmd = { "asm-lsp" },
    root_dir =
        function(fname)
            return vim.fn.getcwd()
        end,
}

servers.fortls = {}

servers.serve_d = {}

M.servers = servers

return M
