-- This snippet fixes the "Invalid 'end_col': out of range" error
-- when calling nvim_buf_set_extmark in Treesitter highlighter.

-- Place this before the call to nvim_buf_set_extmark in:
-- /usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua

-- Clamp end_row and end_col to valid values
local total_lines = vim.api.nvim_buf_line_count(buf)

if end_row >= total_lines then
  end_row = total_lines - 1
end

local line_text = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, true)[1] or ""
local max_col = #line_text

if end_col > max_col then
  end_col = max_col
end
