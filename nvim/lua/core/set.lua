--muda o caracter do <leader> para espaço
vim.g.mapleader = " "

local opts = {
    list = true,
    title = true,

    --ao dividir, divide pra direita e para baixo, e não o oposto
    splitright = true,
    splitbelow = true,

    --se a linha chegar no fim da tela, quebra e mostra ++ na próxima pra
    --que continua na atual
    wrap = true,
    showbreak = '++',

    --ativa os numeros e a numeraçao relativa
    nu = true,
    relativenumber = true,

    --4 espacos tab, a revolucao
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,

    --sem backup amigo
    swapfile = false,
    backup = false,

    --indentação inteligente
    smartindent = true,
    copyindent = true,

    --cria um arquivo de undo, para deixar a undo tree mais op
    undodir = os.getenv("HOME") .. "/.vim/undodir",
    undofile = true,

    hlsearch = false,
    incsearch = true,

    -- destaca a linha onde tá o cursor
    cursorline = true,
    termguicolors = true,

    -- deixa o lualine mostrar o modo
    showmode = false,

    -- guia de identação
    listchars = {
        tab = "⟩ ",
        precedes = "<",
        extends = ">",
        trail = "␣",
        nbsp = "⍽",
        leadmultispace = "▏   ",
        space = "·",
    },

    --sempre mostra as 10 primeiras/ultimas linhas, exceto se for começo/fim do
    --documento
    scrolloff = 10,
    sidescrolloff = 10,

    --eu preciso ver onde o texto quebra, nao me julgue
    colorcolumn = "81",

    -- muda um pouco o funcionamente da cmdline
    cmdwinheight = 10,
    cmdheight = 1,

    -- um folding basico eh melhor que folding nenhum
    foldmethod = "indent",
    fillchars = {
        fold = " ",
    },
    foldenable = true,
    foldlevel = 99,
    foldminlines = 1,
    foldtext = 'v:lua.Utils.custom_fold_text()',

    -- caracteres especiais ativados no regexp
    magic = true,

    -- sempre mostra a signcolumn, mesmo sem conteudo
    signcolumn = 'yes',
}

for k, v in pairs(opts) do
    vim.opt[k] = v
end
