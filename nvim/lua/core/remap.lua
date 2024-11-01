vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = Utils.map

local normal = {
    ["<C-h>"] = {
        "<C-w>h",
        "Focus on the split on the right"
    },
    ["<C-j>"] = {
        "<C-w>j",
        "Focus on the lower split"
    },
    ["<C-k>"] = {
        "<C-w>k",
        "Focus on the upper split"
    },
    ["<C-l>"] = {
        "<C-w>l",
        "Focus on the split on the right"
    },
    ["<C-d>"] = {
        "<C-d>zz",
        "Scroll half page down"
    },
--  ["<C-u>"] = {
--      "<C-u>zz",
--      "Scroll half page up"
--  },
    ["n"] = {
        "nzzzv",
        "Next ocurrence of the searched term"
    },
    ["N"] = {
        "Nzzzv",
        "Previous ocurrence of the searched term"
    },
    ["cd"] = {
        Utils.set_curdir,
        "Sets working directory to current directory",
    },
    ["<C-A-j>"] = {
        "<cmd>resize -3<cr>",
        "Reduces horizontal size of current split"
    },
    ["<C-A-k>"] = {
        "<cmd>resize +3<cr>",
        "Increases horizontal size of current split"
    },
    ["<C-A-l>"] = {
        "<cmd>vertical resize -3<cr>",
        "Reduces vertical size of current split"
    },
    ["<C-A-h>"] = {
        "<cmd>vertical resize +3<cr>",
        "Increases vertical size of current split"
    },
    ["<leader>s"] = {
        ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gc<Left><Left><Left>",
        "Substitutes word under cursor"
    },
    ["<leader>a"] = {
        "<cmd>%y+<cr>",
        "Yanks all text on buffer"
    },
    ["<a-j>"] = {
        "<cmd>m .+1<cr>==",
        "Moves current line down"
    },
    ["<a-k>"] = {
        "<cmd>m .-2<cr>==",
        "Moves current line up"
    },
    ["<leader><BS>"] = {
        "<cmd>bd<cr>",
        "Deletes buffer"
    },
    ["<S-TAB>"] = {
        "<cmd>bn<cr>",
        "Next buffer"
    },
    ["<C-TAB>"] = {
        "<cmd>b#<cr>",
        "Previous buffer"
    },
    ["x"] = {
        "\"_x",
        "Deletes a single caracter"
    },
    ["<C-w>v"] = {
        "<cmd>vsplit<cr>",
        "Creates a vertical split"
    },
    ["<C-w>s"] = {
        "<cmd>split<cr>",
        "Creates a horizontal split"
    },
    ["<C-w>w"] = {
        "<C-w>w",
        "Go to next split"
    },
    ["<C-w>p"] = {
        "<C-w>p",
        "Go to previous split"
    },
    ["<leader>-"] = {
        "<C-x>",
        "Decrease number by one"
    },
    ["<leader>+"] = {
        "<C-a>",
        "Increase number by one"
    },
    ["<leader>y"] = {
        "\"+y",
        "Yank to system clipboard"
    },
    ["<leader>Y"] = {
        "\"+Y",
        "Yank to system clipboard"
    },
    ["<leader>p"] = {
        "\"+p",
        "Paste from the system clipboard"
    },
    ["<leader>P"] = {
        "\"+P",
        "Paste from the system clipboard"
    }
}

local insert = {
    ["jk"] = {
        "<esc>",
        "Exits insert mode"
    },
    ["kj"] = {
        "<esc>",
        "Exits insert mode"
    },
    ["<c-s>"] = {
        "<esc>:w<cr>a",
        "Write current buffer"
    },
    ["<a-j>"] = {
        "<esc><cmd>m .+1<cr>==gi",
        "Move current line down"
    },
    ["<a-k>"] = {
        "<esc><cmd>m .-2<cr>==gi",
        "Move current line up"
    },
}

local visual = {
    ["<c-c>"] = {
        "<esc>",
        "Exits visual mode"
    },
    ["<a-j>"] = {
        ":m '>+1<cr>gv-gv",
        "Move current line down"
    },
    ["<a-k>"] = {
        ":m '<lt>-2<CR>gv-gv",
        "Move current line up"
    },
    ["<"] = {
        "<gv",
        "Indent text to left"
    },
    [">"] = {
        ">gv",
        "Indent text to right"
    },
    ["x"] = {
        '"_x',
        "Deletes a single caracter"
    },
    ["<leader>y"] = {
        "\"+y",
        "Yank to system clipboard"
    },
    ["<leader>Y"] = {
        "\"+Y",
        "Yank to system clipboard"
    },
    ["<leader>p"] = {
        "\"+p",
        "Paste from the system clipboard"
    },
    ["<leader>P"] = {
        "\"+P",
        "Paste from the system clipboard"
    }
}

map("n", normal)
map("i", insert)
map("x", visual)

local movement = {
    ["j"] = {
        "v:count ? 'j' : 'gj'",
        "Go down one visual line"
    },
    ["k"] = {
        "v:count ? 'k' : 'gk'",
        "Go up one visual line"
    },
}
map("n", movement, { expr = true })
map("x", movement, { expr = true })
