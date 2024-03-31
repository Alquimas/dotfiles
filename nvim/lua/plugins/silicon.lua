return {
    'segeljakt/vim-silicon',
    lazy = false,
    config = function ()
        local opts = {
            theme = '1337',
            font = 'Hack',
            output = '~/Imagens/codeshots/silicon-{time:%Y-%m-%d-%H%M%S}.png',
            background = '#AAAAAA',
        }
        opts['shadow-color'] = '#555555'
        opts['line-pad'] = 2
        opts['pad-horiz'] = 10
        opts['pad-vert'] = 12
        opts['shadow-blur-radius'] = 0
        opts['shadow-offset-x'] = 0
        opts['shadow-offset-y'] = 0
        opts['line-number'] = false
        opts['round-corner'] = true
        opts['window-controls'] = false
        vim.g.silicon = opts
    end
}
