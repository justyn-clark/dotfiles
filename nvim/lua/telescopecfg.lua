-- ~/.dotfiles/nvim/lua/telescopecfg.lua
-- Telescope file and text search.

local ok, telescope = pcall(require, "telescope")
if not ok then
  return
end

telescope.setup({})

local builtin = require("telescope.builtin")
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>ff", builtin.find_files, vim.tbl_extend("force", opts, { desc = "Find files" }))
map("n", "<leader>fg", builtin.live_grep, vim.tbl_extend("force", opts, { desc = "Live grep" }))
map("n", "<leader>fb", builtin.buffers, vim.tbl_extend("force", opts, { desc = "Find buffers" }))
map("n", "<leader>fh", builtin.help_tags, vim.tbl_extend("force", opts, { desc = "Help tags" }))
