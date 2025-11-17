---File finding utilities for Obsidian links

local M = {}

---Normalize filename by removing block references and aliases
---@param filename string
---@return string
function M.normalize_filename(filename)
  -- Remove block references (e.g., "file#block" -> "file")
  -- Remove aliases (e.g., "file|alias" -> "file")
  filename = filename:match("^([^#|]+)") or filename
  -- Trim whitespace
  filename = vim.fn.trim(filename)
  return filename
end

---Find a file in the Obsidian vault using multiple search strategies
---@param link_text string The link text from [[...]]
---@param config table Configuration table with vault_path and file_extensions
---@return string? Full path to file if found, nil otherwise
function M.find_file(link_text, config)
  local filename = M.normalize_filename(link_text)
  local vault_path = config.vault_path
  
  -- Ensure the vault directory exists
  if vim.fn.isdirectory(vault_path) == 0 then
    return nil
  end
  
  -- Strategy 1: Try exact matches in root directory first
  for _, ext in ipairs(config.file_extensions) do
    local full_path = vault_path .. "/" .. filename .. ext
    if vim.fn.filereadable(full_path) == 1 then
      return full_path
    end
  end
  
  -- Strategy 2: Recursive search using find (case-insensitive)
  local escaped_base = vim.fn.shellescape(vault_path)
  
  local find_patterns = {}
  for _, ext in ipairs(config.file_extensions) do
    table.insert(find_patterns, string.format(
      'find %s -type f -iname %s 2>/dev/null',
      escaped_base,
      vim.fn.shellescape(filename .. ext)
    ))
  end
  
  -- Also try without extension
  table.insert(find_patterns, string.format(
    'find %s -type f -iname %s 2>/dev/null',
    escaped_base,
    vim.fn.shellescape(filename)
  ))
  
  -- Partial match for files with variations
  for _, ext in ipairs(config.file_extensions) do
    table.insert(find_patterns, string.format(
      'find %s -type f -iname %s 2>/dev/null | head -1',
      escaped_base,
      vim.fn.shellescape("*" .. filename .. "*" .. ext)
    ))
  end
  
  for _, cmd in ipairs(find_patterns) do
    local result = vim.fn.system(cmd)
    if result and result ~= "" and vim.v.shell_error == 0 then
      local lines = vim.split(result, "\n")
      for _, line in ipairs(lines) do
        local trimmed = vim.fn.trim(line)
        if trimmed ~= "" and vim.fn.filereadable(trimmed) == 1 then
          return trimmed
        end
      end
    end
  end
  
  -- Strategy 3: Use globpath for Lua-native file searching
  local glob_patterns = {}
  for _, ext in ipairs(config.file_extensions) do
    table.insert(glob_patterns, filename .. ext)
    table.insert(glob_patterns, "**/" .. filename .. ext)
  end
  table.insert(glob_patterns, filename)
  table.insert(glob_patterns, "**/" .. filename)
  
  for _, pattern in ipairs(glob_patterns) do
    local files_str = vim.fn.globpath(vault_path, pattern)
    if files_str and files_str ~= "" then
      local files = vim.split(files_str, "\n")
      for _, file in ipairs(files) do
        if file and file ~= "" then
          local full_path = vault_path .. "/" .. file
          if file:match("^/") then
            full_path = file
          end
          if vim.fn.filereadable(full_path) == 1 then
            return full_path
          end
        end
      end
    end
  end
  
  return nil
end

return M

