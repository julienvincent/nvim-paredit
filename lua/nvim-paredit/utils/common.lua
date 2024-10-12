local M = {}

function M.included_in_table(table, item)
  for _, value in pairs(table) do
    if value == item then
      return true
    end
  end
  return false
end

function M.chunk_table(tbl, chunk_size)
  local result = {}
  for i = 1, #tbl, chunk_size do
    local chunk = {}
    for j = 0, chunk_size - 1 do
      if tbl[i + j] then
        table.insert(chunk, tbl[i + j])
      end
    end
    table.insert(result, chunk)
  end
  return result
end

-- Compares the two given { col, row } position tuples and returns -1/0/1 depending
-- on whether `a` is less than, equal to or greater than `b`
--
-- compare_positions({ 0, 1 }, { 0, 0 }) => 1
-- compare_positions({ 0, 1 }, { 1, 0 }) => -1
-- compare_positions({ 1, 1 }, { 1, 1 }) => 0
function M.compare_positions(a, b)
  if a[1] > b[1] then
    return 1
  elseif a[1] == b[1] then
    if a[2] == b[2] then
      return 0
    elseif a[2] > b[2] then
      return 1
    end
  end
  return -1
end

-- Removes all extra keys from t1 which is not in original
-- and returns a new table
--
-- intersection({ "a", "b", "f", "d"}, {"a", "b", "c"}) => { "a", "b" }
function M.intersection(tbl, original)
  local original_set = {}
  for _, v in ipairs(original) do
    original_set[v] = true
  end

  local result = {}
  for _, v in ipairs(tbl) do
    if original_set[v] then
      table.insert(result, v)
    end
  end

  return result
end

function M.ordered_set(lines)
  local seen = {}
  local result = {}
  for _, value in ipairs(lines) do
    if not seen[value] then
      table.insert(result, value)
      seen[value] = true
    end
  end

  table.sort(result)
  return result
end

function M.ensure_visual_mode()
  if vim.api.nvim_get_mode().mode ~= "v" then
    vim.api.nvim_command("normal! v")
  end
end

M.default_whitespace_chars = { " " }

function M.is_whitespace_under_cursor(lang)
  local cursor = vim.api.nvim_win_get_cursor(0)
  cursor = { cursor[1] - 1, cursor[2] }

  local char_under_cursor = vim.api.nvim_buf_get_text(0, cursor[1], cursor[2], cursor[1], cursor[2] + 1, {})
  return M.included_in_table(lang.whitespace_chars or M.default_whitespace_chars, char_under_cursor[1])
    or char_under_cursor[1] == ""
end

return M
