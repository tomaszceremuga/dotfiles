-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll half-page down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll half-page up and center" })

map("i", "<C-c>", "<Esc>", { desc = "Ctrl-C acts like Escape" })
map("n", "<C-c>", "<Esc>", { desc = "Ctrl-C acts like Escape" })
map("v", "<C-c>", "<Esc>", { desc = "Ctrl-C acts like Escape" })

map("n", "<C-v>", '"+p', { desc = "Paste from system clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from system clipboard" })
map("v", "<C-v>", '"+p', { desc = "Paste from system clipboard" })

map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "gl", ":!xdg-open <cWORD><CR>", { desc = "Open URL under cursor" })

map("n", "<leader>n", function()
  vim.opt.number = not vim.opt.number:get()
  vim.opt.relativenumber = false

  if vim.g.snacks_indent_enabled then
    Snacks.indent.disable()
  else
    Snacks.indent.enable()
  end

  vim.g.snacks_indent_enabled = not vim.g.snacks_indent_enabled
end)
