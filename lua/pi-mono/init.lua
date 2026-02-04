---pi-mono.nvim public API
---Integration for pi AI coding assistant with Neovim
local M = {}

---Setup pi-mono.nvim with user options
---@param opts pi.Opts|nil
function M.setup(opts)
  if opts then
    vim.g.pi_opts = vim.tbl_deep_extend("force", vim.g.pi_opts or {}, opts)
    -- Reload config to apply new options
    package.loaded["pi-mono.config"] = nil
  end
end

M.ask = require("pi-mono.ui.ask").ask
M.select = require("pi-mono.ui.select").select

M.prompt = require("pi-mono.api.prompt").prompt
M.operator = require("pi-mono.api.operator").operator
M.command = require("pi-mono.api.command").command

M.toggle = require("pi-mono.provider").toggle
M.start = require("pi-mono.provider").start
M.stop = require("pi-mono.provider").stop
M.send = require("pi-mono.provider").send

return M
