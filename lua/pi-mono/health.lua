local M = {}

function M.check()
  vim.health.start("pi-mono.nvim")

  -- Check for pi binary
  local config = require("pi-mono.config")
  local binary = config.opts.binary or "pi"

  local binary_path = vim.fn.exepath(binary)
  if binary_path ~= "" then
    vim.health.ok("pi binary found: " .. binary_path)

    -- Try to get version
    local result = vim.system({ binary, "--version" }, { text = true }):wait()
    if result.code == 0 and result.stdout then
      vim.health.info("Version: " .. vim.trim(result.stdout))
    end
  else
    vim.health.error("pi binary not found: " .. binary, {
      "Install pi: npm install -g @mariozechner/pi-coding-agent",
      "Or set a custom binary path in vim.g.pi_opts.binary",
    })
  end

  -- Check for snacks.nvim
  local snacks_ok, snacks = pcall(require, "snacks")
  if snacks_ok then
    vim.health.ok("snacks.nvim is available")

    -- Check for terminal support
    if snacks.config and snacks.config.get then
      local terminal_config = snacks.config.get("terminal", {})
      if terminal_config.enabled ~= false then
        vim.health.ok("snacks.terminal is enabled")
      else
        vim.health.warn("snacks.terminal is not enabled", {
          "Enable snacks.terminal in your snacks.nvim configuration",
        })
      end
    end
  else
    vim.health.warn("snacks.nvim is not available", {
      "Install snacks.nvim for best experience",
      "pi-mono.nvim will fall back to vim.ui.select",
    })
  end

  -- Check provider
  local provider = config.get_provider()
  if provider then
    vim.health.ok("Provider configured: " .. (provider.name or "unknown"))

    if provider.health then
      local healthy, advice = provider:health()
      if healthy == true then
        vim.health.ok("Provider health check passed")
      else
        vim.health.warn("Provider health check: " .. tostring(healthy), advice or {})
      end
    end
  else
    vim.health.warn("No provider configured")
  end
end

return M
