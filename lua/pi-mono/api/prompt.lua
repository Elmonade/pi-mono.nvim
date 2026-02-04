local M = {}

---@class pi.api.prompt.Opts
---@field clear? boolean Clear the input before.
---@field submit? boolean Submit the input after.
---@field context? pi.Context The context the prompt is being made in.

---Send a prompt to pi.
---@param prompt string
---@param opts? pi.api.prompt.Opts
function M.prompt(prompt, opts)
  local config = require("pi-mono.config")

  -- Resolve referenced prompt if it exists
  local referenced_prompt = config.opts.prompts[prompt]
  prompt = referenced_prompt and referenced_prompt.prompt or prompt

  opts = {
    clear = opts and opts.clear or false,
    submit = opts and opts.submit or false,
    context = opts and opts.context or require("pi-mono.context").new(),
  }

  -- Render context placeholders
  local rendered = opts.context:render(prompt)
  local plaintext = opts.context.plaintext(rendered.output)

  -- Ensure pi is running
  local provider = config.get_provider()
  if not provider then
    vim.notify("No pi provider configured", vim.log.levels.ERROR, { title = "pi-mono" })
    return
  end

  -- Start pi if needed
  provider:start()

  -- Send the prompt text to the terminal
  -- For pi in TUI mode, we send text directly
  vim.defer_fn(function()
    if opts.clear then
      -- Send Ctrl+C to clear current input
      provider:send("\x03")
      vim.defer_fn(function()
        provider:send(plaintext)
        if opts.submit then
          -- Enter is already added by send()
        end
      end, 100)
    else
      provider:send(plaintext)
    end
    opts.context:clear()
  end, 200)
end

return M
