# confirm-quit

This plugin will give you a confirmation message when you close the last window. It prevents Neovim from closing unexpectedly.

![2021-04-07_22-15](https://user-images.githubusercontent.com/8683947/113873204-8fc59280-97ef-11eb-82b3-1c8b55373277.png)

## Installation

```lua
-- Lazy
{ "yutkat/confirm-quit.nvim", event = "CmdlineEnter", config = true },

-- Packer
use {
  "yutkat/confirm-quit.nvim",
  event = "CmdlineEnter",
  config = function() require "confirm-quit".setup() end,
}
```

## Keymaps

```lua
-- :q
vim.keymap.set("n", "<leader>q", require "confirm-quit".confirm_quit)

-- :qa
vim.keymap.set("n", "<leader>Q", function() require "confirm-quit".confirm_quit(true) end)
```
