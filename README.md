# pi-mono.nvim

Neovim integration for [pi](https://github.com/mariozechner/pi-mono), an AI coding assistant.

## Features

- Embedded pi terminal via [snacks.nvim](https://github.com/folke/snacks.nvim)
- Context-aware prompts with placeholders (`@this`, `@buffer`, `@diagnostics`, etc.)
- Operator support for sending ranges to pi
- Pre-configured prompts for common tasks (explain, review, fix, test, etc.)
- Fully customizable configuration

## Requirements

- Neovim >= 0.10.0
- [pi](https://github.com/mariozechner/pi-mono) binary installed
- [snacks.nvim](https://github.com/folke/snacks.nvim) (recommended, for terminal and picker support)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jello/pi-mono.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    vim.g.pi_opts = {
      binary = "pi-mono", -- or "pi" depending on your installation
    }

    -- Keymaps
    vim.keymap.set({ "n", "x" }, "<C-a>", function()
      require("pi-mono").ask("@this: ", { submit = true })
    end, { desc = "Ask pi" })

    vim.keymap.set({ "n", "x" }, "<C-x>", function()
      require("pi-mono").select()
    end, { desc = "Execute pi action" })

    vim.keymap.set({ "n", "t" }, "<C-.>", function()
      require("pi-mono").toggle()
    end, { desc = "Toggle pi" })
  end,
}
```

## Configuration

Configure via `vim.g.pi_opts` before loading the plugin:

```lua
vim.g.pi_opts = {
  -- The pi binary to use
  binary = "pi-mono",

  -- Context placeholders that can be used in prompts
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

  -- Pre-configured prompts
  prompts = {
    explain = { prompt = "Explain @this and its context", submit = true },
    review = { prompt = "Review @this for correctness and readability", submit = true },
    fix = { prompt = "Fix @diagnostics", submit = true },
    test = { prompt = "Add tests for @this", submit = true },
    -- Add your own...
  },

  -- Provider configuration
  provider = {
    enabled = "snacks", -- or "terminal"
    snacks = {
      win = {
        position = "right",
        enter = true,
      },
    },
  },
}
```

## API

### Core Functions

- `require("pi-mono").ask(default?, opts?)` - Open input prompt for pi
- `require("pi-mono").select()` - Open action picker
- `require("pi-mono").prompt(text, opts?)` - Send prompt to pi
- `require("pi-mono").command(cmd)` - Send command to pi (e.g., "new_session", "abort")
- `require("pi-mono").operator(prompt, opts?)` - Operator for sending ranges

### Provider Functions

- `require("pi-mono").toggle()` - Toggle pi terminal
- `require("pi-mono").start()` - Start pi terminal
- `require("pi-mono").stop()` - Stop pi terminal
- `require("pi-mono").send(text)` - Send raw text to pi terminal

## Context Placeholders

Use these in prompts to include context from your editor:

| Placeholder | Description |
|-------------|-------------|
| `@this` | Current selection or cursor position |
| `@buffer` | Current buffer path |
| `@buffers` | All open buffer paths |
| `@visible` | Visible lines in all windows |
| `@diagnostics` | LSP diagnostics for current buffer |
| `@quickfix` | Quickfix list entries |
| `@diff` | Git diff output |
| `@marks` | Global marks |

## Health Check

Run `:checkhealth pi-mono` to verify your setup.

## License

MIT
