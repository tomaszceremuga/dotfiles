return {

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- {
  --   "RedsXDD/neopywal.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("neopywal").setup()
  --     vim.cmd("colorscheme neopywal")
  --   end,
  -- },

  "mbbill/undotree",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
  },

  {
    "folke/snacks.nvim",
    opts = {
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
            cmd = "cat ~/.config/nvim/lua/img2.txt",
            -- chafa ~/Pictures/joker.jpg --format symbols --symbols vhalf --size 60x17 --stretch > ~/.config/nvim/lua/img.txt
            height = 17,
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
}
