return {
    "catppuccin/nvim",
    lazy = false,
    config = function ()
        local catppuccin = require("catppuccin")
        local opts = {
            highlight_overrides = {
                all = function(colors)
                    return {
                    }
                end,
                latte = function(latte)
                    return {
                    }
                end,
                frappe = function(frappe)
                    return {
                    }
                end,
                macchiato = function(macchiato)
                    return {
                    }
                end,
                mocha = function(mocha)
                    return {
                        Folded = {
                            bg = mocha.none,
                        },
                    }
                end,
            },
        }
        catppuccin.setup(opts)
    end
}
