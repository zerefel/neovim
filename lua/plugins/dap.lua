return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim",
  },
  opts = function()
    local dap = require("dap")

    -- Configure js-debug-adapter for Node.js debugging
    if not dap.adapters["pwa-node"] then
      require("dap").adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            require("mason-registry").get_package("js-debug-adapter"):get_install_path()
              .. "/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }
    end

    -- Node.js attach configuration
    for _, language in ipairs({ "typescript", "javascript" }) do
      if not dap.configurations[language] then
        dap.configurations[language] = {}
      end

      table.insert(dap.configurations[language], {
        type = "pwa-node",
        request = "attach",
        name = "Attach to Node.js (nodemon)",
        -- Connect to the inspector port, not PID
        port = 5858,
        address = "localhost",
        restart = true,
        sourceMaps = true,
        protocol = "inspector",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      })
    end
  end,
}
