-- ~/.dotfiles/nvim/lua/dapcfg.lua
-- Optional DAP (Debug Adapter Protocol) configuration
-- Inert unless nvim-dap is installed and adapters are present.
-- ----------------------------------------------------------

local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
  return
end

-- Keymaps (only set if dap loaded)
local map = vim.keymap.set
map("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
map("n", "<F10>", dap.step_over, { desc = "DAP: Step over" })
map("n", "<F11>", dap.step_into, { desc = "DAP: Step into" })
map("n", "<F12>", dap.step_out, { desc = "DAP: Step out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })

-- Python (debugpy) --------------------------------------------------
-- Install: pip install --user debugpy
dap.adapters.python = {
  type = "executable",
  command = "python3",
  args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      local venv = os.getenv("VIRTUAL_ENV")
      if venv then
        return venv .. "/bin/python"
      end
      return "python3"
    end,
  },
}

-- Go (delve) ---------------------------------------------------------
-- Install: go install github.com/go-delve/delve/cmd/dlv@latest
dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = {
    command = "dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
  },
}

dap.configurations.go = {
  {
    type = "delve",
    name = "Launch",
    request = "launch",
    program = "${file}",
  },
  {
    type = "delve",
    name = "Test (go test)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}",
  },
}

-- Node (vscode-js-debug) ---------------------------------------------
-- Install: clone vscode-js-debug, npm install, npm run compile
-- Then point js_debug_path to the build directory.
local js_debug_path = vim.fn.stdpath("data") .. "/vscode-js-debug"

local js_ok, _ = pcall(function()
  if vim.fn.isdirectory(js_debug_path) == 1 then
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = { js_debug_path .. "/src/dapDebugServer.js", "${port}" },
      },
    }

    for _, lang in ipairs({ "javascript", "typescript" }) do
      dap.configurations[lang] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
      }
    end
  end
end)

if not js_ok then
  -- silently skip if vscode-js-debug is not installed
end
