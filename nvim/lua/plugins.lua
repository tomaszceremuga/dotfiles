return {
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },

    "mbbill/undotree",
    keys = {
        { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },

    {
        "folke/snacks.nvim",
        opts = {
            indent = {
                enabled = false
            },
            dashboard = {
                preset = {
                    keys = {
                        { icon = " ", key = "c", desc = "Config", action = ":e $MYVIMRC" },
                        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                    },
                },
                sections = {
                    {
                        section = "terminal",
                        cmd = "cat ~/.config/nvim/lua/img.txt",
                        -- chafa ~/img.png  --format symbols --symbols vhalf --size 60x17 --stretch > ~/.config/nvim/lua/img.txt
                        height = 26,
                        padding = 1,
                    },
                    { section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1 },
                    { section = "projects", icon = " ", title = "Projects", indent = 2, padding = 1 },
                    { section = "keys", gap = 0, padding = 1 },
                },
            },
        },
    },

    {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
            local wal = vim.fn.json_decode(vim.fn.readfile(os.getenv("HOME") .. "/.cache/wal/colors.json"))
            local c = wal.colors
            local bg = wal.special.background
            local fg = wal.special.foreground

            opts.options = {
                section_separators = "",
                component_separators = "",
                icons_enabled = false,
                theme = {
                    normal = {
                        a = { fg = bg, bg = c.color1, gui = "bold" },
                        z = { fg = bg, bg = c.color1, gui = "bold" },
                        b = { fg = fg, bg = bg },
                        c = { fg = fg, bg = bg },
                    },
                    insert = {
                        a = { fg = bg, bg = c.color4, gui = "bold" },
                        z = { fg = bg, bg = c.color4, gui = "bold" },
                    },
                    visual = {
                        a = { fg = bg, bg = c.color7, gui = "bold" },
                        z = { fg = bg, bg = c.color7, gui = "bold" },
                    },
                    inactive = {
                        a = { fg = fg, bg = bg },
                        z = { fg = fg, bg = bg },
                    },
                },
            }

            opts.sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { "filename" },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            }
        end,
    },

    {
        "anAcc22/sakura.nvim",
        dependencies = "rktjmp/lush.nvim",
        config = function()
            vim.opt.background = "dark"
            local colors_path = os.getenv("HOME") .. "/.cache/wal/colors.json"
            if vim.fn.filereadable(colors_path) == 1 then
                local wal = vim.fn.json_decode(vim.fn.readfile(colors_path))
                local bg = (wal and wal.special and wal.special.background) or "#1e1e2e"
                vim.cmd.colorscheme("sakura")
                local groups =
                { "Normal", "NormalNC", "NormalFloat", "SignColumn", "StatusLine", "StatusLineNC", "VertSplit", "Pmenu" }
                for _, g in ipairs(groups) do
                    vim.api.nvim_set_hl(0, g, { bg = bg })
                end
            else
                vim.cmd.colorscheme("sakura")
            end
        end,
    },
    {
        "akinsho/bufferline.nvim",
        enabled = false,
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")

            harpoon:setup()

            vim.keymap.set("n", "<leader>a", function()
                harpoon:list():add()
            end, { desc = "Harpoon: add file" })

            vim.keymap.set("n", "<leader>h", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end, { desc = "Harpoon: menu" })

            vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon: file 1" })
            vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon: file 2" })
            vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon: file 3" })
            vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon: file 4" })

            vim.keymap.set("n", "<leader>]", function()
                harpoon:list():next()
            end, { desc = "Harpoon: next" })

            vim.keymap.set("n", "<leader>[", function()
                harpoon:list():prev()
            end, { desc = "Harpoon: prev" })
        end,
    },

    {
        'mikesmithgh/borderline.nvim',
        enabled = true,
        lazy = true,
        event = 'VeryLazy',
        config = function()
            require('borderline').setup({
                border = "single",
            })
        end,
    }
}
