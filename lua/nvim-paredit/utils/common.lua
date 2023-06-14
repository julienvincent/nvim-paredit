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

function M.cursor_out_of_bounds(cursor, pos)
  if cursor[1] > pos[1] + 1 then
    return true
  elseif cursor[1] == pos[1] + 1 then
    if cursor[2] > pos[2] then
      return true
    end
  end
  return false
end

return M
