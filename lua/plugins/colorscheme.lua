vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#45475a", nocombine = true }) -- Example: a color close to macchiato's mantle/base

return {
  -- Catppuccin theme plugin
  {
    "catppuccin/nvim",
    name = "catppuccin", -- Ensure the name is specified
    priority = 1000, -- Load this theme early
    opts = { -- Configuration for Catppuccin
      flavour = "macchiato",
      transparent_background = true,
      styles = {
        comments = { "italic" }, -- Enable italic for comments
        keywords = {}, -- Disable italic for keywords
        functions = {},
        variables = {},
      },
      custom_highlights = function(color)
        return {
          SnacksIndent = { fg = color.surface0 },
          SnacksIndentScope = { fg = color.surface2 },
          SnacksIndentBlank = { fg = color.surface0 },
        }
      end,
    },
  },
  -- LazyVim configuration for colorscheme and highlights
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin", -- Set the colorscheme
      highlights = function()
        return {
          Comment = { italic = true }, -- Enable italic for comments
          Normal = { italic = false }, -- Disable italic for normal text
          ["*"] = { italic = false },
        }
      end,
    },
  },
}
