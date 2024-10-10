local traversal = require("nvim-paredit.utils.traversal")
local common = require("nvim-paredit.utils.common")
local ts_utils = require("nvim-paredit.utils.ts")
local ts = require("nvim-treesitter.ts_utils")
local config = require("nvim-paredit.config")
local langs = require("nvim-paredit.lang")

local M = {}

function M.drag_form_forwards()
  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
  })
  if not current_form then
    return
  end

  local root = lang.get_node_root(current_form)

  local sibling = root:next_named_sibling()
  if not sibling then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  ts.swap_nodes(root, sibling, buf, true)
end

function M.drag_form_backwards()
  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
  })
  if not current_form then
    return
  end

  local root = lang.get_node_root(current_form)

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
  local lang = langs.get_language_api()
  local current_node = lang.get_node_root(ts.get_node_at_cursor())
  if not current_node then
    return
  end

  local pairwise_nodes = ts_utils.find_pairwise_nodes(
    current_node,
    vim.tbl_deep_extend("force", opts, {
      lang = lang,
    })
  )
  if not pairwise_nodes then
    local parent = current_node:parent()
    if not parent then
      return
    end

    pairwise_nodes = traversal.get_children_ignoring_comments(parent, {
      lang = lang,
    })
  end

  drag_node_in_pair(current_node, pairwise_nodes, opts)
end

local function drag_element(opts)
  local lang = langs.get_language_api()
  local current_node = lang.get_node_root(ts.get_node_at_cursor())

  if opts.dragging.auto_drag_pairs then
    local pairwise_nodes = ts_utils.find_pairwise_nodes(current_node, { lang = lang })
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
