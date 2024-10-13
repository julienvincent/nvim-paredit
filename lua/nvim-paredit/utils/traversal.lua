local ts_forms = require("nvim-paredit.treesitter.forms")
local ts_utils = require("nvim-paredit.treesitter.utils")

local M = {}

function M.get_children_ignoring_comments(node, opts)
  local children = {}

  local index = 0
  local child = node:named_child(index)
  while child do
    if not ts_utils.node_is_comment(child, opts) then
      table.insert(children, child)
    end
    index = index + 1
    child = node:named_child(index)
  end

  return children
end

local function get_child_ignoring_comments(node, index, opts)
  if index < 0 or index >= node:named_child_count() then
    return
  end
  local child = node:named_child(index)
  if not child then
    return
  end
  if ts_utils.node_is_comment(child, opts) then
    return get_child_ignoring_comments(node, index + opts.direction, opts)
  end
  return child
end

function M.get_last_child_ignoring_comments(node, opts)
  return get_child_ignoring_comments(node, node:named_child_count() - 1, {
    direction = -1,
    captures = opts.captures,
  })
end

function M.get_first_child_ignoring_comments(node, opts)
  return get_child_ignoring_comments(node, 0, {
    direction = 1,
    captures = opts.captures,
  })
end

function M.find_closest_form_with_children(current_node, opts)
  local form = ts_forms.get_form_inner(current_node, opts)
  if form:named_child_count() > 0 and not ts_utils.is_document_root(current_node) then
    return form
  end

  local parent = current_node:parent()
  if parent then
    return M.find_closest_form_with_children(parent, opts)
  end
end

local function find_closest_form_with_siblings(current_node, fn)
  if fn(current_node) then
    return current_node
  end
  local parent = current_node:parent()
  if parent then
    return find_closest_form_with_siblings(parent, fn)
  end
end

function M.find_closest_form_with_next_siblings(current_form)
  return find_closest_form_with_siblings(current_form, function(node)
    return node:next_named_sibling()
  end)
end

function M.find_closest_form_with_prev_siblings(current_form)
  return find_closest_form_with_siblings(current_form, function(node)
    return node:prev_named_sibling()
  end)
end

local function get_sibling_ignoring_comments(node, opts)
  local sibling = opts.sibling_fn(node)
  if not sibling then
    return opts.sibling or nil, opts.count + 1
  end

  if ts_utils.node_is_comment(sibling, opts) then
    return get_sibling_ignoring_comments(sibling, opts)
  elseif opts.count > 1 then
    local new_opts = vim.tbl_deep_extend("force", opts, {
      count = opts.count - 1,
      sibling = sibling,
    })
    return get_sibling_ignoring_comments(sibling, new_opts)
  end

  return sibling, opts.count
end

function M.get_next_sibling_ignoring_comments(node, opts)
  return get_sibling_ignoring_comments(node, {
    captures = opts.captures,
    count = opts.count or 1,
    sibling_fn = function(n)
      return n:next_named_sibling()
    end,
  })
end

function M.get_prev_sibling_ignoring_comments(node, opts)
  return get_sibling_ignoring_comments(node, {
    captures = opts.captures,
    count = opts.count or 1,
    sibling_fn = function(n)
      return n:prev_named_sibling()
    end,
  })
end

return M
