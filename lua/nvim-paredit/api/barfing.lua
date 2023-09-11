local traversal = require("nvim-paredit.utils.traversal")
local indentation = require("nvim-paredit.indentation")
local common = require("nvim-paredit.utils.common")
local ts = require("nvim-treesitter.ts_utils")
local config = require("nvim-paredit.config")
local langs = require("nvim-paredit.lang")

local M = {}

function M.barf_forwards(opts)
  opts = opts or {}

  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    use_source = false,
    lang = lang,
  })
  if not current_form then
    return
  end

  local form = traversal.find_closest_form_with_children(current_form, {
    lang = lang,
  })
  if not form or form:type() == "source" then
    return
  end

  local child
  if opts.reversed then
    child = traversal.get_first_child_ignoring_comments(form, {
      lang = lang,
    })
  else
    child = traversal.get_last_child_ignoring_comments(form, {
      lang = lang,
    })
  end
  if not child then
    return
  end

  local edges = lang.get_form_edges(form)

  local sibling = traversal.get_prev_sibling_ignoring_comments(child, {
    lang = lang,
  })

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

  local cursor_behaviour = opts.cursor_behaviour or config.config.cursor_behaviour
  if cursor_behaviour == "auto" or cursor_behaviour == "follow" then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor_out_of_bounds = common.compare_positions({ cursor_pos[1] - 1, cursor_pos[2] }, end_pos) == 1
    if cursor_behaviour == "follow" or cursor_out_of_bounds then
      vim.api.nvim_win_set_cursor(0, { end_pos[1] + 1, end_pos[2] })
    end
  end

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

  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    use_source = false,
    lang = lang,
  })
  if not current_form then
    return
  end

  local form = traversal.find_closest_form_with_children(current_form, {
    lang = lang,
  })
  if not form or form:type() == "source" then
    return
  end

  local child = traversal.get_first_child_ignoring_comments(form, {
    lang = lang,
  })
  if not child then
    return
  end

  local edges = lang.get_form_edges(lang.get_node_root(form))

  local sibling = traversal.get_next_sibling_ignoring_comments(child, {
    lang = lang,
  })

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

  local cursor_behaviour = opts.cursor_behaviour or config.config.cursor_behaviour
  if cursor_behaviour == "auto" or cursor_behaviour == "follow" then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor_out_of_bounds = common.compare_positions(end_pos, { cursor_pos[1] - 1, cursor_pos[2] }) == 1
    if cursor_behaviour == "follow" or cursor_out_of_bounds then
      vim.api.nvim_win_set_cursor(0, { end_pos[1] + 1, end_pos[2] })
    end
  end

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
