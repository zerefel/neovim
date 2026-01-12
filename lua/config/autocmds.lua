-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable auto-format on save for JSON files to preserve blank lines
-- Manual format with <leader>cf still works
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- remove the default format on save autocommand
-- pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_format_on_save")
--
-- -- format on save with eslint
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = vim.api.nvim_create_augroup("format_on_save_eslint", { clear = true }),
--   pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
--   callback = function()
--     vim.lsp.buf.format({
--       filter = function(client)
--         return client.name == "eslint"
--       end,
--       async = true,
--     })
--   end,
-- })

--
-- TypeScript autoimports
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
--   callback = function()
--     local params = {
--       command = "_typescript.organizeImports",
--       arguments = { vim.api.nvim_buf_get_name(0) },
--       title = "",
--     }
--     vim.lsp.buf.execute_command(params)
--   end,
-- })
