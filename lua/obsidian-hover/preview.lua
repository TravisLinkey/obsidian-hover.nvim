---Preview window management for Obsidian hover

local M = {}
local preview_win = nil

---Close the preview window if it's open
function M.close()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
    preview_win = nil
  end
end

---Check if preview window is currently open
---@return boolean
function M.is_open()
  return preview_win ~= nil and vim.api.nvim_win_is_valid(preview_win)
end

---Show preview window with file contents
---@param filepath string? Full path to file, or nil if not found
---@param link_text string The link text
---@param config table Configuration table
function M.show(filepath, link_text, config)
  -- Close existing preview if open
  M.close()

  local lines = {}
  if filepath then
    local success, file_lines = pcall(vim.fn.readfile, filepath)
    if success and file_lines then
      -- Limit to configured max lines
      local max_lines = math.min(config.max_preview_lines, #file_lines)
      for i = 1, max_lines do
        table.insert(lines, file_lines[i])
      end
      if #file_lines > config.max_preview_lines then
        table.insert(lines, "...")
      end
    else
      lines = { "Error reading file" }
    end
  else
    lines = { "File not found" }
  end

  -- Calculate window dimensions
  local width = math.min(config.preview_width, vim.o.columns - 10)
  local height = math.min(#lines + 2, config.preview_height)
  
  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  -- Window options
  local opts = {
    relative = "cursor",
    width = width,
    height = height,
    col = 2,
    row = 1,
    style = "minimal",
    border = config.border,
  }

  -- Create floating window
  preview_win = vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_win_set_option(preview_win, "winblend", config.winblend)
  vim.api.nvim_win_set_option(preview_win, "wrap", true)
end

return M

