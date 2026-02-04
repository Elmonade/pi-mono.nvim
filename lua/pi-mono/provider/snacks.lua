---Provide an embedded pi via snacks.terminal
---@class pi.provider.Snacks : pi.Provider
---@field opts table
---@field binary string
---@field terminal_win any
local Snacks = {}
Snacks.__index = Snacks
Snacks.name = "snacks"

---@class pi.provider.snacks.Opts

---@param opts? pi.provider.snacks.Opts
---@param binary? string
---@return pi.provider.Snacks
function Snacks.new(opts, binary)
  local self = setmetatable({}, Snacks)
  self.opts = opts or {}
  self.binary = binary or "pi"
  self.terminal_win = nil
  return self
end

---Check if snacks.terminal is available and enabled.
function Snacks.health()
  local snacks_ok, snacks = pcall(require, "snacks")
  if not snacks_ok then
    return "`snacks.nvim` is not available.", {
      "Install `snacks.nvim` and enable `snacks.terminal`.",
    }
  elseif not snacks.config.get("terminal", {}).enabled then
    return "`snacks.terminal` is not enabled.", {
      "Enable `snacks.terminal` in your `snacks.nvim` configuration.",
    }
  end

  return true
end

function Snacks:get()
  local opts = vim.tbl_deep_extend("force", self.opts, { create = false })
  local win = require("snacks.terminal").get(self.binary, opts)
  return win
end

function Snacks:toggle()
  local win = require("snacks.terminal").toggle(self.binary, self.opts)
  self.terminal_win = win
end

function Snacks:start()
  if not self:get() then
    local win = require("snacks.terminal").open(self.binary, self.opts)
    self.terminal_win = win
  end
end

function Snacks:stop()
  local win = self:get()
  if win then
    win:close()
    self.terminal_win = nil
  end
end

---Send text to the pi terminal
---@param text string
function Snacks:send(text)
  local win = self:get()
  if not win then
    -- Start pi first
    self:start()
    -- Wait a bit for terminal to be ready
    vim.defer_fn(function()
      self:send(text)
    end, 500)
    return
  end

  -- Get the terminal buffer and send text
  local buf = win.buf
  if buf and vim.api.nvim_buf_is_valid(buf) then
    local chan = vim.bo[buf].channel
    if chan > 0 then
      -- Send text to terminal (with newline to submit)
      vim.api.nvim_chan_send(chan, text .. "\n")
    end
  end
end

return Snacks
