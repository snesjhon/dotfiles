return function(use)
    use({
        "projekt0n/github-nvim-theme",
        config = function()
            require("github-theme").setup({
                theme_style = "light",
            })
        end
    })
    use({
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require("nvim-tree").setup({
                sort_by = "case_sensitive",
                view = {
                    side = "right",
                    width = 30,
                    mappings = {
                        list = {
                            { key = "u", action = "dir_up" },
                        },
                    },
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = true,
                },
            })
        end
    })
    use({
        'f-person/auto-dark-mode.nvim',
        config = function()
            local auto_dark_mode = require('auto-dark-mode')
            auto_dark_mode.setup({
                update_interval = 1000,
                set_dark_mode = function()
                    vim.api.nvim_set_option('background', 'github_dark')
                    vim.cmd('colorscheme github_dark')
                end,
                set_light_mode = function()
                    vim.api.nvim_set_option('background', 'github_light')
                    vim.cmd('colorscheme github_dark')
                end,
            })
            auto_dark_mode.init()
        end
    })
end
