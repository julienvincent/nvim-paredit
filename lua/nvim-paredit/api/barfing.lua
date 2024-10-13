local ts_context = require("nvim-paredit.treesitter.context")
local ts_forms = require("nvim-paredit.treesitter.forms")
local ts_utils = require("nvim-paredit.treesitter.utils")
local traversal = require("nvim-paredit.utils.traversal")
local indentation = require("nvim-paredit.indentation")
local common = require("nvim-paredit.utils.common")
local config = require("nvim-paredit.config")

local M = {}

local function position_cursor_according_to_edge(params)
  if params.cursor_behaviour == "remain" then
    return
  end

  local cursor_behaviour = params.cursor_behaviour or "auto"
  local current_pos = vim.api.nvim_win_get_cursor(0)

  local cursor_out_of_bounds
  if params.reversed then
    cursor_out_of_bounds = common.compare_positions(params.edge_pos, current_pos) == 1
  else
    cursor_out_of_bounds = common.compare_positions(current_pos, params.edge_pos) == 1
  end

  if cursor_behaviour == "follow" then
    vim.api.nvim_win_set_cursor(0, params.edge_pos)
  elseif cursor_behaviour == "auto" and cursor_out_of_bounds then
    vim.api.nvim_win_set_cursor(0, params.edge_pos)
  end
end

function M.barf_forwards(opts)
  opts = opts or {}

  local context = ts_context.create_context(opts)
  if not context then
    return
  end

  local current_form = ts_forms.find_nearest_form(context.node, context)
  if not current_form then
    return
  end

  local form = traversal.find_closest_form_with_children(current_form, context)
  if not form or ts_utils.is_document_root(form) then
    return
  end

  local child
  if opts.reversed then
    child = traversal.get_first_child_ignoring_comments(form, context)
  else
    child = traversal.get_last_child_ignoring_comments(form, context)
  end
  if not child then
    return
  end

  local edges = ts_forms.get_form_edges(form, context)

  local sibling = traversal.get_prev_sibling_ignoring_comments(child, context)

  local end_pos
  if sibling then
    end_pos = { sibling:end_() }
  else
    end_pos = { edges.left.range[3], edges.left.range[4] }
  end

  local buf = vim.api.nvim_get_current_buf()

  local range = edges.right.range
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    range[1], range[2],
    range[3], range[4],
    {}
  )

  local text = edges.right.text
  -- stylua: ignore
  vim.api.nvim_buf_set_text(buf,
    end_pos[1], end_pos[2],
    end_pos[1], end_pos[2],
    { text }
  )

  position_cursor_according_to_edge({
    cursor_behaviour = opts.cursor_behaviour or config.config.cursor_behaviour,
    edge_pos = { end_pos[1] + 1, end_pos[2] },
  })

  local event = {
    type = "barf-forwards",
    -- stylua: ignore
    parent_range = {
      edges.left.range[1], edges.left.range[2],
      end_pos[1], end_pos[2],
    },
  }
  indentation.handle_indentation(event, opts)
end

function M.barf_backwards(opts)
  opts = opts or {}

  local context = ts_context.create_context(opts)
  if not context then
    return
  end

  local current_form = ts_forms.find_nearest_form(context.node, context)
  if not current_form then
    return
  end

  local form = traversal.find_closest_form_with_children(current_form, context)
  if not form or ts_utils.is_document_root(form) then
    return
  end

  local child = traversal.get_first_child_ignoring_comments(form, context)
  if not child then
    return
  end

  local edges = ts_forms.get_form_edges(ts_forms.get_node_root(form, context), context)

  local sibling = traversal.get_next_sibling_ignoring_comments(child, context)

  local end_pos
  if sibling then
    end_pos = { sibling:start() }
  else
    end_pos = { edges.right.range[1], edges.right.range[2] }
  end

  local buf = vim.api.nvim_get_current_buf()

  local text = edges.left.text
  -- stylua: ignore
  vim.api.nvim_buf_set_text(buf,
    end_pos[1], end_pos[2],
    end_pos[1], end_pos[2],
    { text }
  )

  local range = edges.left.range
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    range[1], range[2],
    range[3], range[4],
    {}
  )

  position_cursor_according_to_edge({
    reversed = true,
    cursor_behaviour = opts.cursor_behaviour or config.config.cursor_behaviour,
    edge_pos = { end_pos[1] + 1, end_pos[2] },
  })

  local event = {
    type = "barf-backwards",
    -- stylua: ignore
    parent_range = {
      end_pos[1], end_pos[2],
      edges.right.range[1], edges.right.range[2],
    },
  }
  indentation.handle_indentation(event, opts)
end

return M
