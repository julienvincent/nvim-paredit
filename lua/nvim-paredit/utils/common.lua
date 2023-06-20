local M = {}

function M.included_in_table(table, item)
  for _, value in pairs(table) do
    if value == item then
      return true
    end
  end
  return false
end

function M.merge(a, b)
  local result = {}
  for k, v in pairs(a) do
    result[k] = v
  end
  for k, v in pairs(b) do
    result[k] = v
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

return M

