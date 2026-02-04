---@class pi.Provider
---@field name? string
---@field binary? string
---@field new? fun(opts: table, binary: string): pi.Provider
---@field toggle? fun(self: pi.Provider)
---@field start? fun(self: pi.Provider)
---@field stop? fun(self: pi.Provider)
---@field send? fun(self: pi.Provider, text: string)
---@field health? fun(): boolean|string, ...string|string[]

---@class pi.provider.Opts
---@field enabled? "terminal"|"snacks"|false
---@field terminal? pi.provider.terminal.Opts
---@field snacks? pi.provider.snacks.Opts

local M = {}

---Toggle pi via the configured provider.
function M.toggle()
  local provider = require("pi-mono.config").get_provider()
  if provider and provider.toggle then
    provider:toggle()
  else
    error("`provider.toggle` unavailable — configure a provider", 0)
  end
end

---Start pi via the configured provider.
function M.start()
  local provider = require("pi-mono.config").get_provider()
  if provider and provider.start then
    provider:start()
  else
    error("`provider.start` unavailable — configure a provider", 0)
  end
end

---Stop pi via the configured provider.
function M.stop()
  local provider = require("pi-mono.config").get_provider()
  if provider and provider.stop then
    provider:stop()
  else
    error("`provider.stop` unavailable — configure a provider", 0)
  end
end

---Send text to pi terminal.
---@param text string
function M.send(text)
  local provider = require("pi-mono.config").get_provider()
  if provider and provider.send then
    provider:send(text)
  else
    error("`provider.send` unavailable — configure a provider", 0)
  end
end

return M
