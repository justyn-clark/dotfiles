-- ~/.dotfiles/nvim/init.lua
-- Minimal Neovim config with LSP and optional DAP
-- ------------------------------------------------

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Basic keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Load modules (guarded so missing plugins don't crash)
local function safe_require(mod)
  local ok, err = pcall(require, mod)
  if not ok then
    vim.notify("Module " .. mod .. " not loaded: " .. err, vim.log.levels.WARN)
  end
end

safe_require("fzf")
safe_require("lsp")
safe_require("dapcfg")
