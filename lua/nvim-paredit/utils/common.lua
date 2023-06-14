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

function M.pos_out_of_bounds(pos, ref)
  if pos[1] > ref[1] then
    return true
  elseif pos[1] == ref[1] then
    if pos[2] > ref[2] then
      return true
    end
  end
  return false
end

return M
