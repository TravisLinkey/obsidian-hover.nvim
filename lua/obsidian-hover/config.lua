---@class ObsidianHoverConfig
---@field vault_path string Path to Obsidian vault directory
---@field keymap string Keymap to trigger hover (default: "K")
---@field max_preview_lines number Maximum lines to show in preview (default: 30)
---@field preview_width number Width of preview window (default: 80)
---@field preview_height number Maximum height of preview window (default: 20)
---@field border string Border style for preview window (default: "rounded")
---@field winblend number Window blend/transparency (0-100, default: 10)
---@field file_extensions string[] File extensions to search for (default: {".md", ".markdown"})
---@field enable_notifications boolean Show notifications when file not found (default: true)

local M = {}

---Default configuration
M.defaults = {
  vault_path = nil, -- Must be set by user
  keymap = "K",
  max_preview_lines = 30,
  preview_width = 80,
  preview_height = 20,
  border = "rounded",
  winblend = 10,
  file_extensions = { ".md", ".markdown" },
  enable_notifications = true,
}

---Merge user config with defaults
---@param user_config ObsidianHoverConfig?
---@return ObsidianHoverConfig
function M.setup(user_config)
  user_config = user_config or {}
  
  -- Merge with defaults
  local config = vim.tbl_deep_extend("force", {}, M.defaults, user_config)
  
  -- Validate required fields
  if not config.vault_path then
    vim.notify(
      "[obsidian-hover] vault_path is required. Please set it in your config.",
      vim.log.levels.ERROR
    )
    error("obsidian-hover: vault_path is required")
  end
  
  -- Expand path
  config.vault_path = vim.fn.expand(config.vault_path)
  
  -- Validate vault path exists
  if vim.fn.isdirectory(config.vault_path) == 0 then
    vim.notify(
      string.format("[obsidian-hover] Vault path does not exist: %s", config.vault_path),
      vim.log.levels.WARN
    )
  end
  
  return config
end

return M

