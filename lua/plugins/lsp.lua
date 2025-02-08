-- make sure that the html formatter doesn't run on templ files
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        templ = { "templ" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false, -- Disable inlay hints globally
      },
    },
  },
}
