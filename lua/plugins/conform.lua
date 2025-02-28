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
      },
    },
  },
}
-- return {
-- {
--   "stevearc/conform.nvim",
--   opts = {
--     formatters_by_ft = {
--       sql = { "pg_format" },
--       pgsql = { "pg_format" },
--     },
--     formatters = {
--       pg_format = {
--         command = "pg_format",
--       },
--     },
--   },
-- },
