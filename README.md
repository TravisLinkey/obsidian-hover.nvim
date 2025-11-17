# obsidian-hover.nvim

A Neovim plugin that shows previews of linked Obsidian notes when hovering over `[[Link Name]]` patterns in markdown files.

## Features

- 🎯 **Smart File Finding**: Automatically searches for linked files in your Obsidian vault
- 🔍 **Multiple Search Strategies**: Tries exact matches, recursive search, and glob patterns
- 📖 **Preview Window**: Shows a floating preview window with the linked note's contents
- ⌨️ **Toggle Support**: Press the keymap again to close the preview
- ⚙️ **Highly Configurable**: Customize vault path, keymaps, preview size, and more

## Requirements

- Neovim 0.7.0 or higher
- An Obsidian vault directory

## Installation

### Using lazy.nvim

```lua
{
  "your-username/obsidian-hover.nvim",
  ft = "markdown",
  config = function()
    require("obsidian-hover").setup({
      vault_path = "~/Documents/Obsidian/MyVault",
    })
  end,
}
```

### Using packer.nvim

```lua
use({
  "your-username/obsidian-hover.nvim",
  ft = "markdown",
  config = function()
    require("obsidian-hover").setup({
      vault_path = "~/Documents/Obsidian/MyVault",
    })
  end,
})
```

### Manual Installation

1. Clone this repository into your Neovim config:
   ```bash
   git clone https://github.com/your-username/obsidian-hover.nvim.git ~/.config/nvim/lua/obsidian-hover
   ```

2. Add to your `init.lua`:
   ```lua
   require("obsidian-hover").setup({
     vault_path = "~/Documents/Obsidian/MyVault",
   })
   ```

## Configuration

The plugin accepts a configuration table with the following options:

```lua
require("obsidian-hover").setup({
  -- Required: Path to your Obsidian vault directory
  vault_path = "~/Documents/Obsidian/MyVault",
  
  -- Keymap to trigger hover (default: "K")
  keymap = "K",
  
  -- Maximum lines to show in preview (default: 30)
  max_preview_lines = 30,
  
  -- Width of preview window (default: 80)
  preview_width = 80,
  
  -- Maximum height of preview window (default: 20)
  preview_height = 20,
  
  -- Border style for preview window (default: "rounded")
  -- Options: "none", "single", "double", "rounded", "solid", "shadow"
  border = "rounded",
  
  -- Window blend/transparency (0-100, default: 10)
  winblend = 10,
  
  -- File extensions to search for (default: {".md", ".markdown"})
  file_extensions = { ".md", ".markdown" },
  
  -- Show notifications when file not found (default: true)
  enable_notifications = true,
})
```

## Usage

1. Open a markdown file in Neovim
2. Place your cursor over a `[[Link Name]]` pattern
3. Press `K` (or your configured keymap) to show the preview
4. Press `K` again to close the preview

The plugin will automatically:
- Search for the linked file in your Obsidian vault
- Show a preview window with the file contents
- Display "File not found" if the file doesn't exist
- Close the preview when you leave the buffer

## How It Works

The plugin uses multiple search strategies to find linked files:

1. **Exact Match**: Tries exact filename matches in the vault root
2. **Recursive Search**: Uses `find` command to search recursively (case-insensitive)
3. **Glob Patterns**: Uses Neovim's `globpath` for Lua-native file searching

It handles:
- Files with spaces in names
- Different file extensions (.md, .markdown)
- Block references (`[[file#block]]` → finds `file`)
- Aliases (`[[file|alias]]` → finds `file`)
- Files in subdirectories

## Troubleshooting

### File not found even though file exists

1. Check that `vault_path` is correctly set and points to your Obsidian vault
2. Verify the file exists in the vault directory
3. Check that the link text matches the filename (case-insensitive)
4. Try using the full filename including extension in the link

### Preview window doesn't appear

1. Make sure you're in a markdown file (`:set filetype?` should show `markdown`)
2. Verify your cursor is directly over the `[[Link Name]]` text
3. Check that the plugin is loaded (`:lua require("obsidian-hover")`)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

