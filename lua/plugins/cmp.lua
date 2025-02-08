return {
  "hrsh7th/nvim-cmp",
  opts = function()
    local cmp = require("cmp")
    return {
      mapping = cmp.mapping.preset.insert({
        ["<C-.>"] = cmp.mapping.complete(),
      }),
    }
  end,
}
