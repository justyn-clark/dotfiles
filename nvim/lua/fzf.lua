-- ~/.dotfiles/nvim/lua/fzf.lua
-- fzf.vim keymaps (requires junegunn/fzf.vim plugin)
-- ---------------------------------------------------

local ok = pcall(vim.cmd, "runtime plugin/fzf.vim")
if not ok then
  return
end

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>f", "<cmd>Files<CR>", vim.tbl_extend("force", opts, { desc = "Find files" }))
map("n", "<leader>g", "<cmd>Rg<CR>", vim.tbl_extend("force", opts, { desc = "Ripgrep" }))
map("n", "<leader>b", "<cmd>Buffers<CR>", vim.tbl_extend("force", opts, { desc = "Buffers" }))
map("n", "<leader>h", "<cmd>History<CR>", vim.tbl_extend("force", opts, { desc = "History" }))
