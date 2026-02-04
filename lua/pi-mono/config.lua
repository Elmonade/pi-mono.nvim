---@class pi.Opts
---@field binary? string The pi binary to use (default: "pi")
---@field contexts? table<string, fun(context: pi.Context): string|nil>
---@field prompts? table<string, pi.Prompt>
---@field ask? pi.ask.Opts
---@field select? pi.select.Opts
---@field provider? pi.Provider|pi.provider.Opts

---@class pi.Prompt
---@field prompt string The prompt to send.
---@field ask? boolean Call ask() instead of prompt().
---@field submit? boolean Submit immediately.

---Your pi-mono.nvim configuration via global variable.
---@type pi.Opts|nil
vim.g.pi_opts = vim.g.pi_opts

local M = {}

---@type pi.Opts
local defaults = {
  binary = "pi-mono",
  -- stylua: ignore
  contexts = {
    ["@this"] = function(context) return context:this() end,
    ["@buffer"] = function(context) return context:buffer() end,
    ["@buffers"] = function(context) return context:buffers() end,
    ["@visible"] = function(context) return context:visible_text() end,
    ["@diagnostics"] = function(context) return context:diagnostics() end,
    ["@quickfix"] = function(context) return context:quickfix() end,
    ["@diff"] = function(context) return context:git_diff() end,
    ["@marks"] = function(context) return context:marks() end,
  },
  prompts = {
    ask_append = { prompt = "", ask = true },
    ask_this = { prompt = "@this: ", ask = true, submit = true },
    diagnostics = { prompt = "Explain @diagnostics", submit = true },
    diff = { prompt = "Review the following git diff for correctness and readability: @diff", submit = true },
    document = { prompt = "Add comments documenting @this", submit = true },
    explain = { prompt = "Explain @this and its context", submit = true },
    fix = { prompt = "Fix @diagnostics", submit = true },
    implement = { prompt = "Implement @this", submit = true },
    optimize = { prompt = "Optimize @this for performance and readability", submit = true },
    review = { prompt = "Review @this for correctness and readability", submit = true },
    test = { prompt = "Add tests for @this", submit = true },
  },
  ask = {
    prompt = "Ask pi: ",
    snacks = {
      icon = "󰚩 ",
      win = {
        title_pos = "left",
        relative = "cursor",
        row = -3,
        col = 0,
      },
    },
  },
  select = {
    prompt = "pi: ",
    sections = {
      prompts = true,
      commands = {
        ["new_session"] = "Start a new session",
        ["abort"] = "Abort the current operation",
        ["compact"] = "Compact the session context",
        ["cycle_model"] = "Cycle to the next model",
        ["cycle_thinking_level"] = "Cycle thinking level",
      },
      provider = true,
    },
    snacks = {
      preview = "preview",
      layout = {
        preset = "vscode",
        hidden = {},
      },
    },
  },
  provider = {
    enabled = "snacks",
    terminal = {
      split = "right",
      width = math.floor(vim.o.columns * 0.35),
    },
    snacks = {
      auto_close = true,
      win = {
        position = "right",
        enter = false,
        wo = {
          winbar = "",
        },
        bo = {
          filetype = "pi_terminal",
        },
      },
    },
  },
}

---Plugin options, lazily merged from defaults and vim.g.pi_opts.
---@type pi.Opts
M.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.g.pi_opts or {})

-- Allow removing default contexts and prompts by setting them to false
local user_opts = vim.g.pi_opts or {}
for _, field in ipairs({ "contexts", "prompts" }) do
  if user_opts[field] and M.opts[field] then
    for k, v in pairs(user_opts[field]) do
      if not v then
        M.opts[field][k] = nil
      end
    end
  end
end

---The pi provider resolved from opts.provider.
---@type pi.Provider|nil
M.provider = nil

-- Lazy initialization of provider
local function get_provider()
  if M.provider then
    return M.provider
  end

  local provider_or_opts = M.opts.provider
  if provider_or_opts and provider_or_opts.enabled then
    local ok, resolved_provider = pcall(require, "pi-mono.provider." .. provider_or_opts.enabled)
    if not ok then
      vim.notify("Failed to load pi provider '" .. provider_or_opts.enabled .. "': " .. resolved_provider, vim.log.levels.ERROR, { title = "pi-mono" })
      return nil
    end

    local resolved_provider_opts = provider_or_opts[provider_or_opts.enabled]
    M.provider = resolved_provider.new(resolved_provider_opts, M.opts.binary)
  end

  return M.provider
end

M.get_provider = get_provider

return M
