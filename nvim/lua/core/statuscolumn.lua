function GetStatusColumnFmt()
    if vim.api.nvim_buf_get_name(0):match("^oil") then
        return ""
    end
    local wo = vim.wo[vim.g.statusline_winid]
    local components = { "%s" }
    local foldlevel = vim.fn.foldlevel

    if wo.number or wo.relativenumber then
        local linenr = " "
        if vim.v.virtnum == 0 then
            if wo.number and not wo.relativenumber then
                linenr = vim.v.lnum
            elseif not wo.number and wo.relativenumber then
                linenr = vim.v.relnum
            else
                linenr = vim.v.relnum ~= 0 and vim.v.relnum or vim.v.lnum
            end
        end
        linenr = "%=" .. linenr .. " "
        table.insert(components, linenr)
    end

    if wo.foldenable then
        local foldchar = " "
        local hl = vim.fn.line(".") == vim.v.lnum and
                    "CursorLineFold" or "FoldColumn"
        if vim.v.virtnum == 0 and foldlevel(vim.v.lnum)
            and foldlevel(vim.v.lnum) > foldlevel(vim.v.lnum - 1) then
            foldchar = vim.fn.foldclosed(vim.v.lnum) == -1 and "" or ""
        else
            foldchar = "│"
        end
        foldchar = string.format("%%#%s#%s%%*", hl, foldchar)
        table.insert(components, foldchar)
    else
        local hl = vim.fn.line(".") == vim.v.lnum and
                    "CursorLineFold" or "FoldColumn"
        local foldchar = string.format("%%#%s#%s%%*", hl, "│")
        table.insert(components, foldchar)
    end

    table.insert(components, " ")
    return table.concat(components, "")
end

vim.opt.statuscolumn = "%!v:lua.GetStatusColumnFmt()"
