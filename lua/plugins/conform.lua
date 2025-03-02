return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      sql = { "sqlfluff" },
      pgsql = { "sqlfluff" },
    },
    formatters = {
      sqlfluff = {
        command = "sqlfluff",
        args = { "format", "--dialect=postgres", "-" },
        stdin = true,
        cwd = function()
          return vim.fn.getcwd() -- Use current working directory
          -- Or return a specific path:
          -- return "/path/to/your/project"
        end,
      },
    },
  },
}
