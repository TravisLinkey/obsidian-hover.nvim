---@tag obsidian-hover
---@brief [[
---Obsidian Hover - Preview Obsidian note links in Neovim
---
---Show previews of linked Obsidian notes when hovering over `[[Link Name]]` patterns
---in markdown files. Press 'K' (or your configured keymap) to show the preview.
---@brief ]]

local config_module = require("obsidian-hover.config")
local file_finder = require("obsidian-hover.file_finder")
local preview = require("obsidian-hover.preview")

local M = {}
M.config = nil

---Setup the plugin
---@param user_config table? Configuration table
function M.setup(user_config)
  M.config = config_module.setup(user_config)
  M._setup_autocmds()
  M._setup_keymaps()
end

---Setup autocmds
function M._setup_autocmds()
  local group = vim.api.nvim_create_augroup("ObsidianHover", { clear = true })
  
  -- Clean up preview when leaving buffer
  vim.api.nvim_create_autocmd({ "BufLeave" }, {
    group = group,
    pattern = "*.md",
    callback = preview.close,
  })
end

---Setup keymaps
function M._setup_keymaps()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      vim.keymap.set("n", M.config.keymap, function()
        M.show_hover()
      end, {
        buffer = true,
        desc = "Show/toggle Obsidian link preview",
      })
    end,
  })
end

---Extract link text from cursor position
---@return string? Link text if cursor is over a link, nil otherwise
function M._get_link_under_cursor()
  if vim.bo.filetype ~= "markdown" then
    return nil
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  
  -- Pattern to match [[...]] links
  local pattern = "%[%[([^%]]+)%]%]"
  
  -- Find all links in the line
  local start_pos = 1
  local link_start, link_end, link_text = line:find(pattern, start_pos)
  
  while link_start do
    -- Check if cursor is within this link
    if col >= link_start - 1 and col < link_end then
      return link_text
    end
    
    -- Check next link
    start_pos = link_end + 1
    link_start, link_end, link_text = line:find(pattern, start_pos)
  end
  
  return nil
end

---Show hover preview for link under cursor
function M.show_hover()
  if not M.config then
    vim.notify("[obsidian-hover] Plugin not configured. Call require('obsidian-hover').setup()", vim.log.levels.ERROR)
    return
  end

  -- If preview is already open, close it (toggle behavior)
  if preview.is_open() then
    preview.close()
    return
  end

  local link_text = M._get_link_under_cursor()
  
  if not link_text then
    if M.config.enable_notifications then
      vim.notify("No Obsidian link found under cursor", vim.log.levels.INFO)
    end
    return
  end

  -- Find the file
  local filepath = file_finder.find_file(link_text, M.config)
  
  -- Show preview
  preview.show(filepath, link_text, M.config)
end

return M

