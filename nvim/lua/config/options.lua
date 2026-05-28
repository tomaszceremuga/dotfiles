vim.opt.cursorline = false

vim.opt.number = false
vim.opt.relativenumber = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.g.miniindentscope_disable = true
vim.g.indent_blankline_enabled = 0

vim.o.winborder = "none"
vim.diagnostic.config({
    float = { border = "none" }
})
