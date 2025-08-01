local common = require("nvim-paredit.utils.common")

local M = {}

-- returns the next node in DFS order, nil if `node` is the last.
function M.dfs_next_node(node)
  if not node then
    return nil
  end
  if node:named_child_count() > 0 then
    return node:named_child(0)
  end
  repeat
    if node:next_named_sibling() then
      return node:next_named_sibling()
    end
    node = node:parent()
  until not node:parent()
end

-- inverse of dfs_next_node
function M.dfs_prev_node(node)
  if not node then
    return nil
  end
  local prev = node:prev_named_sibling()
  if not prev then
    return node:parent()
  end
  while prev:named_child_count() > 0 do
    prev = prev:named_child(prev:named_child_count() - 1)
  end
  return prev
end

function M.is_document_root(node)
  return node and node:tree():root():equal(node)
end

-- Find the root node of the tree `node` is a member of, excluding the root
-- 'source' document.
function M.find_local_root(node)
  local current = node
  while true do
    local next = current:parent()
    if not next or M.is_document_root(next) then
      break
    end
    current = next
  end
  return current
end

-- Find the root most parent of the given `child` node which is still contained within
-- the given `root` node.
--
-- This is useful to discover the element that we need to operate on within an enclosing
-- form. As an example, take the following senario with the cursor indicated with `|`:
--
-- (:keyword '|(a))
--
-- The enclosing `(` `)` brackets would be given as `root` while the inner list would be
-- given as `child`. The inner list may be wrapped in a `quoting` node, which is the
-- actual node we are wanting to operate on.
function M.find_root_element_relative_to(root, child)
  local parent = child:parent()
  if not parent then
    return child
  end
  if root:equal(parent) then
    return child
  end
  return M.find_root_element_relative_to(root, parent)
end

function M.node_is_comment(node, opts)
  if node:extra() then
    return true
  end

  if node:type() == "comment" then
    return true
  end

  if common.included_in_table(opts.captures[node:id()] or {}, "comment") then
    return true
  end

  return false
end

local function node_to_lsp_range(node)
  local start_line, start_col, end_line, end_col = vim.treesitter.get_node_range(node)
  local rtn = {}
  rtn.start = { line = start_line, character = start_col }
  rtn["end"] = { line = end_line, character = end_col }
  return rtn
end

local function get_node_text(node, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not node then
    return {}
  end

  -- We have to remember that end_col is end-exclusive
  local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(node)

  if start_row ~= end_row then
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
    if next(lines) == nil then
      return {}
    end
    lines[1] = string.sub(lines[1], start_col + 1)
    -- end_row might be just after the last line. In this case the last line is not truncated.
    if #lines == end_row - start_row + 1 then
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
    return lines
  else
    local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
    -- If line is nil then the line is empty
    return line and { string.sub(line, start_col + 1, end_col) } or {}
  end
end

function M.swap_nodes(node_or_range1, node_or_range2, bufnr, cursor_to_second)
  if not node_or_range1 or not node_or_range2 then
    return
  end
  local range1 = node_to_lsp_range(node_or_range1)
  local range2 = node_to_lsp_range(node_or_range2)

  local text1 = get_node_text(node_or_range1, bufnr)
  local text2 = get_node_text(node_or_range2, bufnr)

  local edit1 = { range = range1, newText = table.concat(text2, "\n") }
  local edit2 = { range = range2, newText = table.concat(text1, "\n") }
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  vim.lsp.util.apply_text_edits({ edit1, edit2 }, bufnr, "utf-8")

  if cursor_to_second then
    vim.cmd("normal! m'")

    local char_delta = 0
    local line_delta = 0
    if
      range1["end"].line < range2.start.line
      or (range1["end"].line == range2.start.line and range1["end"].character <= range2.start.character)
    then
      line_delta = #text2 - #text1
    end

    if range1["end"].line == range2.start.line and range1["end"].character <= range2.start.character then
      if line_delta ~= 0 then
        --- why?
        --correction_after_line_change =  -range2.start.character
        --text_now_before_range2 = #(text2[#text2])
        --space_between_ranges = range2.start.character - range1["end"].character
        --char_delta = correction_after_line_change + text_now_before_range2 + space_between_ranges
        --- Equivalent to:
        char_delta = #text2[#text2] - range1["end"].character

        -- add range1.start.character if last line of range1 (now text2) does not start at 0
        if range1.start.line == range2.start.line + line_delta then
          char_delta = char_delta + range1.start.character
        end
      else
        char_delta = #text2[#text2] - #text1[#text1]
      end
    end

    vim.api.nvim_win_set_cursor(
      vim.api.nvim_get_current_win(),
      { range2.start.line + 1 + line_delta, range2.start.character + char_delta }
    )
  end
end

return M
