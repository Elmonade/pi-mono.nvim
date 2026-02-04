local M = {}

---Pi commands that can be sent via RPC or terminal commands.
---@alias pi.Command
---| 'new_session'
---| 'abort'
---| 'compact'
---| 'cycle_model'
---| 'cycle_thinking_level'
---| 'get_state'

---Pi terminal commands (slash commands)
local terminal_commands = {
  new_session = "/new",
  compact = "/compact",
  abort = "", -- Escape key
}

---Send a command to pi.
---For TUI mode, this sends the corresponding slash command.
---@param command pi.Command|string
function M.command(command)
  local provider = require("pi-mono.config").get_provider()
  if not provider then
    vim.notify("No pi provider configured", vim.log.levels.ERROR, { title = "pi-mono" })
    return
  end

  -- Ensure pi is running
  provider:start()

  vim.defer_fn(function()
    local cmd = terminal_commands[command]
    if cmd then
      if cmd == "" then
        -- Send escape for abort
        provider:send("\x1b")
      else
        provider:send(cmd)
      end
    else
      -- Try sending as a raw command (e.g., "/" prefix)
      if command:sub(1, 1) ~= "/" then
        command = "/" .. command
      end
      provider:send(command)
    end
  end, 200)
end

return M
