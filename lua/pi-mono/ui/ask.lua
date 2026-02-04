local M = {}

---@class pi.ask.Opts
---@field prompt? string
---@field snacks? table

---@class pi.prompt.Opts
---@field clear? boolean
---@field submit? boolean
---@field context? pi.Context

---Input a prompt for pi.
---@param default? string Text to pre-fill the input with.
---@param opts? pi.prompt.Opts
function M.ask(default, opts)
  opts = opts or {}
  opts.context = opts.context or require("pi-mono.context").new()

  local config = require("pi-mono.config").opts.ask or {}

  ---@type table
  local input_opts = {
    default = default,
    prompt = config.prompt or "Ask pi: ",
    highlight = function(text)
      local rendered = opts.context:render(text)
      local extmarks = {}
      local col = 0
      for _, part in ipairs(rendered.input) do
        local part_text = part[1]
        local part_hl = part[2]
        if part_hl then
          table.insert(extmarks, { col, col + #part_text, part_hl })
        end
        col = col + #part_text
      end
      return extmarks
    end,
    completion = "customlist,v:lua.pi_completion",
  }

  -- Merge snacks options if available
  if config.snacks then
    input_opts = vim.tbl_deep_extend("force", input_opts, config.snacks)
  end

  vim.ui.input(input_opts, function(value)
    if value and value ~= "" then
      opts.context:clear()
      require("pi-mono").prompt(value, opts)
    else
      opts.context:resume()
    end
  end)
end

---Completion function for context placeholders.
---@param ArgLead string
---@param CmdLine string
---@param CursorPos number
---@return table<string>
_G.pi_completion = function(ArgLead, CmdLine, CursorPos)
  local start_idx, end_idx = CmdLine:find("([^%s]+)$")
  local latest_word = start_idx and CmdLine:sub(start_idx, end_idx) or nil

  local completions = {}
  for placeholder, _ in pairs(require("pi-mono.config").opts.contexts or {}) do
    table.insert(completions, placeholder)
  end

  local items = {}
  for _, completion in pairs(completions) do
    if not latest_word then
      local new_cmd = CmdLine .. completion
      table.insert(items, new_cmd)
    elseif completion:find(latest_word, 1, true) == 1 then
      local new_cmd = CmdLine:sub(1, start_idx - 1) .. completion .. CmdLine:sub(end_idx + 1)
      table.insert(items, new_cmd)
    end
  end
  return items
end

return M
