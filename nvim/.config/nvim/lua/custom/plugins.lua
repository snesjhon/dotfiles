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
end
