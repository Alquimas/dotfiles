Utils = {}

Utils.map = function(mode, mappings, opts)
    -- enabled easy mapping syntax
    -- local mapping = {
    --  ["jk"] = "<esc>",
    --  ["<c-s>"] = { ":w<cr>", "Save" },
    -- }
    -- map( "n", mapping, {})

    for k, v in pairs(mappings) do
        opts = opts or {}
        local default = {
            noremap = true,
            silent = true,
        }
        opts = vim.tbl_deep_extend("force", default, opts)
        local value = v
        local desc = ""
        if type(v) == "table" then
            value, desc = v[1], v[2]
        end
        opts["desc"] = desc
        vim.keymap.set(mode, k, value, opts)
    end
end

Utils.set_curdir = function()
    local curdir = vim.fn.expand("%:p:h")
    vim.api.nvim_set_current_dir(curdir)
end

Utils.custom_fold_text = function ()
    local line_count = vim.v.foldend - vim.v.foldstart + 1
    return " ⚡ Lines folded: " .. line_count
end

return Utils
