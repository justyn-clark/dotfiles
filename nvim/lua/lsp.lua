-- ~/.dotfiles/nvim/lua/lsp.lua
-- Minimal LSP configuration (requires nvim-lspconfig on Nvim 0.11+)
-- -----------------------------------------------------------------

if not vim.lsp or not vim.lsp.config or not vim.lsp.enable then
  return
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local bufnr = event.buf
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("K", vim.lsp.buf.hover, "Hover docs")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("<leader>D", vim.lsp.buf.type_definition, "Type definition")
  end,
})

-- Capabilities (enhanced if cmp-nvim-lsp is available)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Servers
local servers = { "lua_ls", "ts_ls", "pyright", "gopls" }

for _, server in ipairs(servers) do
  local server_opts = {
    capabilities = capabilities,
  }

  -- Lua-specific settings to suppress vim global warnings
  if server == "lua_ls" then
    server_opts.settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    }
  end

  vim.lsp.config(server, server_opts)
  vim.lsp.enable(server)
end
