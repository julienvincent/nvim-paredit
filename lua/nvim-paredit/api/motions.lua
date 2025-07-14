local ts_context = require("nvim-paredit.treesitter.context")
local ts_forms = require("nvim-paredit.treesitter.forms")
local whitespace = require("nvim-paredit.api.whitespace")
local traversal = require("nvim-paredit.utils.traversal")
local ts_utils = require("nvim-paredit.treesitter.utils")
local common = require("nvim-paredit.utils.common")

local MOTION_DIRECTIONS = { LEFT = "left", RIGHT = "right" }

local M = {}

-- When the cursor is placed on whitespace within a form then the node returned by
-- the treesitter `get_node_at_cursor` fn is the outer form and not a child within
-- the form.
--
-- For example: `(aaa| bbb)` - the cursor `|` is placed on a whitespace char and so
-- the `get_node_at_cursor` returns "list_lit".
--
-- Motion commands expect to move to the next adjacent node within the form regardless
-- of whether the cursor is currently on a node or not.
--
-- This function attempts to find the next adjacent node from the cursor if the cursor
-- is placed on whitespace.
local function get_next_node_from_cursor(reversed, context)
  local current_node = context.node
  local cursor = vim.api.nvim_win_get_cursor(0)
  cursor = { cursor[1] - 1, cursor[2] }

  if not (ts_forms.node_is_form(current_node, context) and whitespace.is_whitespace_under_cursor()) then
    return ts_forms.get_node_root(current_node, context)
  end

  local start
  local finish
  local step

  if reversed then
    start = current_node:named_child_count() - 1
    finish = 0
    step = -1
  else
    start = 0
    finish = current_node:named_child_count() - 1
    step = 1
  end

  for i = start, finish, step do
    local child = current_node:named_child(i)
    local range = { child:range() }

    local child_is_next = common.compare_positions(range, cursor) == step

    if child_is_next and not ts_utils.node_is_comment(child, context) then
      return child
    end
  end
end

function M._move_to_element(count, reversed, is_head, is_exclusive)
  local context = ts_context.create_context()
  if not context then
    return
  end

  is_exclusive = is_exclusive or false
  is_head = is_head or false

  local current_node = get_next_node_from_cursor(reversed, context)
  if not current_node then
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  cursor_pos = { cursor_pos[1] - 1, cursor_pos[2] }
  local node_edge
  local traversal_fn

  local is_in_middle = false
  if reversed then
    traversal_fn = traversal.get_prev_sibling_ignoring_comments
    if is_head then
      node_edge = { current_node:start() }
      if common.compare_positions(cursor_pos, node_edge) == 1 then
        is_in_middle = true
      end
    end
  else
    traversal_fn = traversal.get_next_sibling_ignoring_comments
    if not is_head then
      node_edge = { current_node:end_() }
      if common.compare_positions({ node_edge[1], node_edge[2] - 1 }, cursor_pos) == 1 then
        is_in_middle = true
      end
    end
  end

  if ts_utils.node_is_comment(current_node, context) then
    count = count + 1
  end
  local next_pos
  if is_in_middle and count == 1 then
    next_pos = node_edge
  else
    if is_in_middle then
      count = count - 1
    end
    local sibling, count_left = traversal_fn(current_node, {
      captures = context.captures,
      count = count,
    })

    if sibling then
      if is_head and count_left > 1 and not reversed then
        is_head = false
        is_exclusive = false
        next_pos = { sibling:end_() }
      elseif is_head then
        next_pos = { sibling:start() }
      else
        next_pos = { sibling:end_() }
      end
    elseif is_head and not reversed then
      -- convert head to tail motion
      is_head = false
      is_exclusive = false
      next_pos = { current_node:end_() }
    end
  end

  if not next_pos then
    return
  end

  local offset = 0
  if is_exclusive then
    if reversed then
      offset = 1
    else
      offset = -1
    end
  end

  if is_head then
    cursor_pos = { next_pos[1] + 1, next_pos[2] + offset }
  else
    cursor_pos = { next_pos[1] + 1, next_pos[2] - 1 + offset }
  end

  -- When the offset results in a negative overflow then we need to adjust to
  -- the last row in the previous col.
  --
  -- To do this we need to first calculate the length of the previous col to
  -- get the end pos.
  if cursor_pos[2] < 0 then
    local line = vim.api.nvim_buf_get_lines(0, cursor_pos[1] - 1, cursor_pos[1], false)[1]
    local line_end_col = vim.fn.strlen(line)

    cursor_pos[1] = cursor_pos[1] - 1
    cursor_pos[2] = line_end_col
  end

  vim.api.nvim_win_set_cursor(0, cursor_pos)
end

-- When in operator-pending mode (`o` or `no`) then we need to switch to
-- visual mode in order for the operator to apply over a range of text.
-- returns true if operator mode is on, false otherwise
local function ensure_visual_if_operator_pending()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "o" or mode == "no" then
    common.ensure_visual_mode()
    return true
  end
  return false
end

local function move_to_form_edge(form_node, direction, context)
  if not form_node then
    return
  end

  local form_edges = ts_forms.get_form_edges(form_node, context)
  local final_cursor_pos = {
    form_edges[direction].range[1] + 1,
    form_edges[direction].range[2],
  }

  vim.api.nvim_win_set_cursor(0, final_cursor_pos)
end

local function cursor_is_at_form_edge(form_node, direction, cur_cursor_pos, context)
  local form_edges = ts_forms.get_form_edges(form_node, context)
  local edge_cursor_pos = {
    form_edges[direction].range[1] + 1,
    form_edges[direction].range[2],
  }

  return common.compare_positions(edge_cursor_pos, cur_cursor_pos) == 0
end

local function move_to_parent_form_edge(direction)
  local context = ts_context.create_context()
  if not context then
    return
  end

  local nearest_form = ts_forms.find_nearest_form(context.node, {
    use_source = false,
    captures = context.captures,
  })
  if not nearest_form then
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  local target_form = nearest_form
  if cursor_is_at_form_edge(target_form, direction, cursor_pos, context) then
    local root = ts_forms.get_node_root(nearest_form, context)
    if not root then
      return
    end
    target_form = root:parent()
  end

  if not target_form or ts_utils.is_document_root(target_form) then
    return
  end

  move_to_form_edge(target_form, direction, context)
end

function M.move_to_prev_element_head()
  local count = vim.v.count1
  ensure_visual_if_operator_pending()
  M._move_to_element(count, true, true)
end

function M.move_to_prev_element_tail()
  local count = vim.v.count1
  local is_operator = ensure_visual_if_operator_pending()
  M._move_to_element(count, true, false, is_operator)
end

function M.move_to_next_element_tail()
  local count = vim.v.count1
  ensure_visual_if_operator_pending()
  M._move_to_element(count, false, false)
end

-- also jumps to current element tail if there is no
-- next element
function M.move_to_next_element_head()
  local count = vim.v.count1
  local is_operator = ensure_visual_if_operator_pending()
  M._move_to_element(count, false, true, is_operator)
end

function M.move_to_parent_form_start()
  move_to_parent_form_edge(MOTION_DIRECTIONS.LEFT)
end

function M.move_to_parent_form_end()
  move_to_parent_form_edge(MOTION_DIRECTIONS.RIGHT)
end

function M.move_to_top_level_form_head()
  local context = ts_context.create_context()
  if not context then
    return
  end

  local current_form = ts_forms.find_nearest_form(context.node, {
    use_source = false,
    captures = context.captures,
  })

  if not current_form then
    return
  end

  local top_level_form = current_form
  while true do
    local root = ts_forms.get_node_root(top_level_form, context)
    if not root then
      break
    end

    local parent = root:parent()
    if not parent or ts_utils.is_document_root(parent) then
      break
    end

    if ts_forms.node_is_form(parent, context) then
      top_level_form = parent
    else
      break
    end
  end

  move_to_form_edge(top_level_form, MOTION_DIRECTIONS.LEFT, context)
end

return M
