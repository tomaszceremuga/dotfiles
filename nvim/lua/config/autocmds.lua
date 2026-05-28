vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        Snacks.indent.disable()
    end,
})
