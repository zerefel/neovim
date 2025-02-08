return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      priority = 1,
      enabled = true,
    },
    animate = {
      duration = {
        step = 5, -- Milliseconds per animation step
        total = 200, -- Maximum animation duration
      },
    },
  },
  config = function()
    local Snacks = require("snacks")
    Snacks.setup(opts)

    -- Explicitly enable indent guides after setup
    Snacks.indent.enable()

    local copilot_exists = pcall(require, "copilot")
    if copilot_exists then
      Snacks.toggle({
        name = "Copilot Completion",
        color = {
          enabled = "azure",
          disabled = "orange",
        },
        get = function()
          return not require("copilot.client").is_disabled()
        end,
        set = function(state)
          if state then
            require("copilot.command").enable()
          else
            require("copilot.command").disable()
          end
        end,
      }):map("<leader>at")
    end
  end,
}
