local ts_context = require("nvim-paredit.treesitter.context")
local ts_forms = require("nvim-paredit.treesitter.forms")
local ts_pairs = require("nvim-paredit.treesitter.pairs")
local traversal = require("nvim-paredit.utils.traversal")
local common = require("nvim-paredit.utils.common")
local ts = require("nvim-treesitter.ts_utils")
local config = require("nvim-paredit.config")

local M = {}

function M.drag_form_forwards()
  local context = ts_context.create_context()
  if not context then
    return
  end

  local current_form = ts_forms.find_nearest_form(context.node, context)
  if not current_form then
    return
  end

  local root = ts_forms.get_node_root(current_form, context)

  local sibling = root:next_named_sibling()
  if not sibling then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  ts.swap_nodes(root, sibling, buf, true)
end

function M.drag_form_backwards()
  local context = ts_context.create_context()
  if not context then
    return
  end

  local current_form = ts_forms.find_nearest_form(context.node, context)
  if not current_form then
    return
  end

  local root = ts_forms.get_node_root(current_form, context)

  local sibling = root:prev_named_sibling()
  if not sibling then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  ts.swap_nodes(root, sibling, buf, true)
end

local function find_current_pair(pairs, current_node)
  for i, pair in ipairs(pairs) do
    for _, node in ipairs(pair) do
      if node:equal(current_node) then
        return i, pair
      end
    end
  end
end

local function drag_node_in_pair(current_node, nodes, opts)
  local direction = 1
  if opts.reversed then
    direction = -1
  end

  local pairs = common.chunk_table(nodes, 2)
  local chunk_index, pair = find_current_pair(pairs, current_node)

  local corresponding_pair = pairs[chunk_index + direction]
  if not corresponding_pair then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  if pair[2] and corresponding_pair[2] then
    ts.swap_nodes(pair[2], corresponding_pair[2], buf, true)
  end
  if pair[1] and corresponding_pair[1] then
    ts.swap_nodes(pair[1], corresponding_pair[1], buf, true)
  end
end

local function drag_pair(opts)
  local context = ts_context.create_context()
  if not context then
    return
  end

  local current_node = ts_forms.get_node_root(context.node, context)
  if not current_node then
    return
  end

  local pairwise_nodes = ts_pairs.find_pairwise_nodes(current_node, context)
  if not pairwise_nodes then
    local parent = current_node:parent()
    if not parent then
      return
    end

    pairwise_nodes = traversal.get_children_ignoring_comments(parent, context)
  end

  drag_node_in_pair(current_node, pairwise_nodes, opts)
end

local function drag_element(opts)
  local context = ts_context.create_context()
  if not context then
    return
  end

  local current_node = ts_forms.get_node_root(context.node, context)
  if not current_node then
    return
  end

  if opts.dragging.auto_drag_pairs then
    local pairwise_nodes = ts_pairs.find_pairwise_nodes(current_node, context)
    if pairwise_nodes then
      return drag_node_in_pair(current_node, pairwise_nodes, opts)
    end
  end

  local sibling
  if opts.reversed then
    sibling = current_node:prev_named_sibling()
  else
    sibling = current_node:next_named_sibling()
  end

  if not sibling then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  ts.swap_nodes(current_node, sibling, buf, true)
end

function M.drag_element_forwards(opts)
  local drag_opts = vim.tbl_deep_extend(
    "force",
    {
      dragging = config.config.dragging or {},
    },
    opts or {},
    {
      reversed = false,
    }
  )
  drag_element(drag_opts)
end

function M.drag_element_backwards(opts)
  local drag_opts = vim.tbl_deep_extend(
    "force",
    {
      dragging = config.config.dragging or {},
    },
    opts or {},
    {
      reversed = true,
    }
  )
  drag_element(drag_opts)
end

function M.drag_pair_forwards()
  drag_pair({
    reversed = false,
  })
end

function M.drag_pair_backwards()
  drag_pair({
    reversed = true,
  })
end

return M
