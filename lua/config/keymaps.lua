-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- move line up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- search terms stay in middle
-- vim.keymap.set("n", "n", "nzzzv")
-- vim.keymap.set("n", "N", "Nzzzv")

-- yank to clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- unbind arrow keys; embrace the future, praise the past
vim.keymap.set("n", "<Up>", "<nop>", { noremap = true })
vim.keymap.set("n", "<Down>", "<nop>", { noremap = true })
vim.keymap.set("n", "<Left>", "<nop>", { noremap = true })
vim.keymap.set("n", "<Right>", "<nop>", { noremap = true })
-- Yank selection and paste below/above (Duplicate selection)
-- Uses normal mode paste (p/P) which generally handles indentation better

vim.keymap.set("v", "<leader>dj", "y'>p", { desc = "Duplicate selection below (respects indent)" })
vim.keymap.set("v", "<leader>dk", "y'<P", { desc = "Duplicate selection above (respects indent)" })
-- Duplicate text objects below/above using :t (copy) command

-- Visual mode duplication (working)
vim.keymap.set("v", "<leader>zj", "y'>p", { desc = "Duplicate selection below (respects indent)" })
vim.keymap.set("v", "<leader>zk", "y'<P", { desc = "Duplicate selection above (respects indent)" })

-- Paragraph duplication (working using :copy)
-- <leader>zapj: Duplicate 'a paragraph' below
vim.keymap.set("n", "<leader>zapj", "vap:co'><CR>", { desc = "Duplicate paragraph below" })
-- <leader>zapk: Duplicate 'a paragraph' above
vim.keymap.set("n", "<leader>zapk", "vap:co'<-1<CR>", { desc = "Duplicate paragraph above" })

-- Function duplication - Using Treesitter API directly to get range
local function duplicate_function(direction)
  -- Ensure Treesitter utils are available
  local ts_utils_ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ts_utils_ok then
    vim.notify("nvim-treesitter.ts_utils not available", vim.log.levels.WARN)
    return
  end

  -- Common function/method node types (add more if needed for your languages)
  -- You might need to inspect treesitter nodes (`:TSNodeUnderCursor`)
  -- in your specific languages to refine this list.
  local function_node_types = {
    "function_definition",
    "function_declaration",
    "method_definition",
    "method_declaration",
    "arrow_function",
    -- Add other relevant types like 'constructor', 'class_definition' if desired
  }
  local function_node_types_set = {}
  for _, v in ipairs(function_node_types) do
    function_node_types_set[v] = true
  end

  -- Find the nearest enclosing function node
  local node = ts_utils.get_node_at_cursor()
  local function_node = nil
  while node do
    if function_node_types_set[node:type()] then
      function_node = node
      break -- Found the innermost function containing the cursor
    end
    node = node:parent()
  end

  if not function_node then
    vim.notify("Could not find surrounding function node.", vim.log.levels.INFO)
    return
  end

  -- Get the 0-indexed start and end rows from Treesitter
  local start_row, _, end_row, _ = function_node:range()

  -- Convert to 1-indexed Vim line numbers
  local vim_start_line = start_row + 1
  local vim_end_line = end_row + 1

  -- Construct and execute the :t (copy) command
  local cmd
  if direction == "below" then
    -- Copy lines vim_start_line to vim_end_line, place below vim_end_line
    cmd = string.format("%d,%dt%d", vim_start_line, vim_end_line, vim_end_line)
  elseif direction == "above" then
    -- Copy lines vim_start_line to vim_end_line, place below (vim_start_line - 1)
    cmd = string.format("%d,%dt%d", vim_start_line, vim_end_line, vim_start_line - 1)
  else
    vim.notify("Invalid direction for duplicate_function", vim.log.levels.ERROR)
    return
  end

  vim.cmd(cmd)
end

-- <leader>zafj: Duplicate current function below (using Treesitter API)
vim.keymap.set("n", "<leader>zafj", function()
  duplicate_function("below")
end, { desc = "Duplicate function below (Treesitter API)" })

-- <leader>zafk: Duplicate current function above (using Treesitter API)
vim.keymap.set("n", "<leader>zafk", function()
  duplicate_function("above")
end, { desc = "Duplicate function above (Treesitter API)" })
