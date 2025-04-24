# confirm-quit

This plugin will give you a confirmation message when you close the last window. It prevents Neovim from closing unexpectedly.

![2021-04-07_22-15](https://user-images.githubusercontent.com/8683947/113873204-8fc59280-97ef-11eb-82b3-1c8b55373277.png)

## Installation

### Lazy

```lua
{
  "yutkat/confirm-quit.nvim",
  event = "CmdlineEnter",
  opts = {},
}
```

### Packer

```lua
use {
  "yutkat/confirm-quit.nvim",
  event = "CmdlineEnter",
  config = function() require "confirm-quit".setup() end,
}
```

## Default options

```lua
{
  overwrite_q_command = true, -- Replaces :q and :qa with :ConfirmQuit and :ConfirmQuitAll
  quit_message = 'Do you want to quit?', -- Message to show when quitting, can be a function returning a string
}
```

## Commands

You do not need to use those commands directly. `:q` and `:qa` are aliases to `:ConfirmQuit` and `:ConfirmQuitAll` if you didn't change the default config.

I also recommend you set `vim.opt.confirm = true` to get prompted if you want to save all the unsaved changes.

```vim
ConfirmQuit " Same as :q, unless it's the last window, in which case it prompts you before taking any action.
ConfirmQuitAll " Similar to :ConfirmQuit. Will always prompt you to quit 

ConfirmQuit! " An alias to :q!
ConfirmQuitAll! " An alias to :qa!
```

## Lua interface

```lua
require "confirm-quit".confirm_quit()     -- :ConfirmQuit
require "confirm-quit".confirm_quit_all() -- :ConfirmQuitAll

require "confirm-quit".confirm_quit { bang = true }     -- ConfirmQuit!
require "confirm-quit".confirm_quit_all { bang = true } -- ConfirmQuitAll!
```

## Keymaps

Here's an example of how you'd set up keymaps:
```lua
vim.keymap.set("n", "<leader>q", require "confirm-quit".confirm_quit)
vim.keymap.set("n", "<leader>Q", require "confirm-quit".confirm_quit_all)
```
