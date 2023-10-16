local traversal = require("nvim-paredit.utils.traversal")
local common = require("nvim-paredit.utils.common")
local ts = require("nvim-treesitter.ts_utils")
local langs = require("nvim-paredit.lang")

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
local function get_next_node_from_cursor(lang, reversed)
  local current_node = ts.get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  cursor = { cursor[1] - 1, cursor[2] }

  if not (lang.node_is_form(current_node) and common.is_whitespace_under_cursor(lang)) then
    return lang.get_node_root(current_node)
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

    if child_is_next and not lang.node_is_comment(child) then
      return child
    end
  end
end

function M._move_to_element(count, reversed, is_head, is_exclusive)
  is_exclusive = is_exclusive or false
  is_head = is_head or false
  local lang = langs.get_language_api()

  local current_node = get_next_node_from_cursor(lang, reversed)
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

  if lang.node_is_comment(current_node) then
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
      lang = lang,
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

local function move_to_form_edge(form_node, direction, lang)
  if not form_node then
    return
  end

  local form_edges = lang.get_form_edges(form_node)
  local final_cursor_pos = {
    form_edges[direction].range[1] + 1,
    form_edges[direction].range[2]
  }

  vim.api.nvim_win_set_cursor(0, final_cursor_pos)
end

local function is_cursor_at_form_edge(form_node, direction, cur_cursor_pos, lang)
  local form_edges = lang.get_form_edges(form_node)
  local edge_cursor_pos = {
    form_edges[direction].range[1] + 1,
    form_edges[direction].range[2]
  }

  return common.compare_positions(edge_cursor_pos, cur_cursor_pos) == 0
end

local function move_to_parent_form_edge(direction)
  local lang = langs.get_language_api()
  local cur_node = ts.get_node_at_cursor()

  local nearest_form_node = traversal.find_nearest_form(cur_node, { lang = lang })
  if not nearest_form_node or nearest_form_node:type() == "source" then
    return
  end

  local cur_cursor_pos = vim.api.nvim_win_get_cursor(0)
  local form_node_to_move_to = nearest_form_node
  while is_cursor_at_form_edge(form_node_to_move_to, direction, cur_cursor_pos, lang)
    do
      form_node_to_move_to = lang.get_node_root(form_node_to_move_to):parent()
      if not form_node_to_move_to or form_node_to_move_to:type() == "source" then
        return
      end
    end

  move_to_form_edge(form_node_to_move_to, direction, lang)
end

function M.move_to_prev_element_head()
  local count = vim.v.count1
  ensure_visual_if_operator_pending()
  M._move_to_element(count, true, true)
end

function M.move_to_prev_element_tail()
  local count = vim.v.count1
  ensure_visual_if_operator_pending()
  M._move_to_element(count, true, false)
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

return M
