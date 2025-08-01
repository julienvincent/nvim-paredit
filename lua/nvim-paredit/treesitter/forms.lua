local ts_utils = require("nvim-paredit.treesitter.utils")
local common = require("nvim-paredit.utils.common")

local M = {}

-- Searches recursively inwards to determine if the given node is a form. The
-- recursion is needed as this function can be given a wrapped node that still
-- represents a form.
--
-- ```scm
-- (quoting_lit
--   (list_lit
--     (kw_lit)) @form)
-- ```
--
-- Given this AST we would want to recurse inwards until we reach the node
-- annotated with @form.
--
-- The recursion can be disabled by passing `opts.recursive = false` which can
-- be useful for using this function to distinguish between wrapped forms and
-- unwrapped forms.
function M.node_is_form(current_node, opts)
  local captures = opts.captures[current_node:id()] or {}

  if common.included_in_table(captures, "form") then
    return true
  end

  if opts.recursive == false then
    return false
  end
  local child = current_node:named_child()
  if not child then
    return false
  end

  return M.node_is_form(child, opts)
end

-- Recursively search up the AST parentry for the first form node.
function M.find_nearest_form(current_node, opts)
  local current = current_node
  while true do
    if M.node_is_form(current, opts) then
      return current
    end

    local parent = current:parent()
    if not parent then
      if type(opts.use_source) == "boolean" and not opts.use_source then
        return nil
      end

      -- We are in the root of the document, which we can consider a form.
      return current
    end

    current = parent
  end
end

local function find_next_parent_form(current_node, captures)
  local is_form = M.node_is_form(current_node, {
    captures = captures,
    recursive = false,
  })
  if is_form then
    return current_node
  end

  local parent = current_node:parent()
  if not parent then
    return current_node
  end

  return find_next_parent_form(parent, captures)
end

function M.get_node_root(node, opts)
  local search_point = node
  if M.node_is_form(node, opts) then
    search_point = node:parent()
  end

  local root = find_next_parent_form(search_point, opts.captures)
  return ts_utils.find_root_element_relative_to(root, node)
end

-- If a wrapped form node is provided this will return the inner most form node
-- which is the node actually containing children elements.
--
-- ```scm
-- (quoting_lit
--   (list_lit
--     (kw_lit)) @form.inner) @form.outer
-- ```
--
-- Given the above AST we would want to extract the `list_lit` annotated in
-- this example with @form.inner.
function M.get_form_inner(form_node, opts)
  local current = form_node
  while true do
    local is_form = M.node_is_form(current, {
      captures = opts.captures,
      recursive = false,
    })
    if is_form then
      return current
    end
    local child = current:named_child(0)
    if not child then
      return current
    end
    current = child
  end
end

-- The anonymous nodes represent the text of the form itself (as apposed to the
-- children of the form).
--
-- For example you might have the following structure:
--
-- ```scm
-- (list_lit
--   "(" @anonymous
--   (kw_lit) @named
--   ")" @anonymous)
-- ```
--
-- We only want to get the last child representing the end of the 'head' of the
-- form.
--
-- That means taking the last anonymous child before a named child OR taking
-- the _second last_ anonymous child if there are no named children.
local function get_last_anon_child_of_form_head(node)
  local total = node:child_count()
  local current
  for i = 0, total, 1 do
    if i == total - 1 then
      return current
    end
    local child = node:child(i)
    if not child then
      return
    end
    if child:named() then
      return current
    end
    current = child
  end
  return current
end

function M.get_form_edges_without_text(node, opts)
  local outer_range = { node:range() }

  local end_node = get_last_anon_child_of_form_head(M.get_form_inner(node, opts))
  if not end_node then
    end_node = node
  end

  local left_end_row, left_end_col = end_node:end_()

  -- stylua: ignore
  local left_range = {
    outer_range[1], outer_range[2],
    left_end_row, left_end_col,
  }
  -- stylua: ignore
  local right_range = {
    outer_range[3], outer_range[4] - 1,
    outer_range[3], outer_range[4],
  }

  return {
    left = {
      range = left_range,
    },
    right = {
      range = right_range,
    },
  }
end

function M.get_form_edges(node, opts)
  local ret = M.get_form_edges_without_text(node, opts)
  local left_range, right_range = ret.left.range, ret.right.range

  -- stylua: ignore
  local left_text = vim.api.nvim_buf_get_text(0,
    left_range[1], left_range[2],
    left_range[3], left_range[4],
    {})
  -- stylua: ignore
  local right_text = vim.api.nvim_buf_get_text(0,
    right_range[1], right_range[2],
    right_range[3], right_range[4],
    {})

  return {
    left = {
      text = left_text[1],
      range = left_range,
    },
    right = {
      text = right_text[1],
      range = right_range,
    },
  }
end

return M
