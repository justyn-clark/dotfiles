-- ~/.dotfiles/nvim/lua/neotree.lua
-- Neo-tree filesystem explorer.

local ok, neotree = pcall(require, "neo-tree")
if not ok then
  return
end

neotree.setup({
  filesystem = {
    follow_current_file = {
      enabled = true,
    },
    use_libuv_file_watcher = true,
  },
})

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle reveal<CR>", {
  noremap = true,
  silent = true,
  desc = "Toggle file tree",
})
