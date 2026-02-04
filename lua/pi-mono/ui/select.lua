local M = {}

---@class pi.select.Opts
---@field prompt? string
---@field sections? table
---@field snacks? table

---Select an action to execute with pi.
function M.select()
  local config = require("pi-mono.config")
  local select_opts = config.opts.select or {}
  local sections = select_opts.sections or {}

  local items = {}

  -- Add prompts
  if sections.prompts then
    for name, prompt_def in pairs(config.opts.prompts or {}) do
      table.insert(items, {
        label = "prompt: " .. name,
        description = prompt_def.prompt,
        action = function()
          if prompt_def.ask then
            require("pi-mono").ask(prompt_def.prompt, { submit = prompt_def.submit })
          else
            require("pi-mono").prompt(prompt_def.prompt, { submit = prompt_def.submit })
          end
        end,
      })
    end
  end

  -- Add commands
  if sections.commands then
    for cmd_name, description in pairs(sections.commands) do
      table.insert(items, {
        label = "command: " .. cmd_name,
        description = description,
        action = function()
          require("pi-mono").command(cmd_name)
        end,
      })
    end
  end

  -- Add provider actions
  if sections.provider then
    table.insert(items, {
      label = "provider: toggle",
      description = "Toggle the pi terminal",
      action = function()
        require("pi-mono").toggle()
      end,
    })
    table.insert(items, {
      label = "provider: start",
      description = "Start pi",
      action = function()
        require("pi-mono.provider").start()
      end,
    })
    table.insert(items, {
      label = "provider: stop",
      description = "Stop pi",
      action = function()
        require("pi-mono.provider").stop()
      end,
    })
  end

  -- Sort items by label
  table.sort(items, function(a, b)
    return a.label < b.label
  end)

  -- Use snacks.picker if available, otherwise vim.ui.select
  local snacks_ok, snacks = pcall(require, "snacks")
  if snacks_ok and snacks.picker then
    snacks.picker.pick({
      source = "pi-mono",
      title = select_opts.prompt or "pi: ",
      items = vim.tbl_map(function(item)
        return {
          text = item.label .. " " .. (item.description or ""),
          item = item,
        }
      end, items),
      format = function(item)
        return {
          { item.item.label, "Function" },
          { " " },
          { item.item.description or "", "Comment" },
        }
      end,
      confirm = function(picker, selected)
        picker:close()
        if selected and selected.item then
          selected.item.action()
        end
      end,
    })
  else
    vim.ui.select(items, {
      prompt = select_opts.prompt or "pi: ",
      format_item = function(item)
        return item.label .. " - " .. (item.description or "")
      end,
    }, function(selected)
      if selected then
        selected.action()
      end
    end)
  end
end

return M
