local traversal = require("nvim-paredit.utils.traversal")
local utils = require("nvim-paredit.indentation.utils")
local common = require("nvim-paredit.utils.common")
local langs = require("nvim-paredit.lang")

local M = {}

local function dedent_lines(lines, delta, opts)
  -- stylua: ignore
  local line_text = vim.api.nvim_buf_get_lines(
    opts.buf or 0,
    lines[1], lines[#lines] + 1,
    false
  )

  local smallest_distance = delta
  for _, line in ipairs(line_text) do
    local first_char_index = string.find(line, "[^%s]")
    if first_char_index and (first_char_index - 1) < smallest_distance then
      smallest_distance = first_char_index - 1
    end
  end

  for index, line in ipairs(lines) do
    local deletion_range = smallest_distance
    local contains_chars = string.find(line_text[index], "[^%s]")
    if not contains_chars then
      deletion_range = #line_text[index]
    end
    -- stylua: ignore
    vim.api.nvim_buf_set_text(
      opts.buf or 0,
      line, 0,
      line, deletion_range,
      {}
    )
  end

  return smallest_distance
end

local function indent_lines(lines, delta, opts)
  if delta == 0 then
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(opts.buf or 0)
  local cursor_delta = delta

  if delta < 0 then
    cursor_delta = dedent_lines(lines, delta * -1, opts) * -1
  else
    local chars = string.rep(" ", delta)
    for _, line in ipairs(lines) do
      -- stylua: ignore
      vim.api.nvim_buf_set_text(
        opts.buf or 0,
        line, 0,
        line, 0,
        {chars}
      )
    end
  end

  if common.included_in_table(lines, cursor_pos[1] - 1) then
    vim.api.nvim_win_set_cursor(opts.buf or 0, { cursor_pos[1], cursor_pos[2] + cursor_delta })
  end
end

local function indent_barf(event)
  local lang = langs.get_language_api()

  local lhs
  local node
  if event.type == "barf-forwards" then
    node = traversal.get_next_sibling_ignoring_comments(event.parent, { lang = lang })
    lhs = event.parent
  else
    node = event.parent
    lhs = traversal.get_prev_sibling_ignoring_comments(event.parent, { lang = lang })
  end

  if not node or not lhs then
    return
  end

  local parent = node:parent()

  local lhs_range = { lhs:range() }
  local node_range = { node:range() }

  if not utils.node_is_first_on_line(node, { lang = lang }) or lhs_range[1] == node_range[1] then
    return
  end

  local lines = utils.find_affected_lines(node, utils.get_node_line_range(node_range))

  local delta
  if parent:type() == "source" then
    delta = node_range[2]
  else
    local row
    local ref_node = utils.get_first_sibling_on_upper_line(node, { lang = lang })
    if ref_node then
      local range = { ref_node:range() }
      row = range[2]
    else
      local form_edges = lang.get_form_edges(parent)
      row = form_edges.left.range[2] - 1
    end

    delta = node_range[2] - row
  end

  indent_lines(lines, delta * -1, {
    buf = event.buf,
  })
end

local function indent_slurp(event)
  local parent = event.parent
  local lang = langs.get_language_api()

  local child
  if event.type == "slurp-forwards" then
    child = parent:named_child(parent:named_child_count() - 1)
  else
    child = parent:named_child(1)
  end

  local parent_range = { parent:range() }
  local child_range = { child:range() }

  if not utils.node_is_first_on_line(child, { lang = lang }) or parent_range[1] == child_range[1] then
    return
  end

  local lines = utils.find_affected_lines(child, utils.get_node_line_range(child_range))

  local row
  local ref_node = utils.get_first_sibling_on_upper_line(child, { lang = lang })
  if ref_node then
    local range = { ref_node:range() }
    row = range[2]
  else
    local form_edges = lang.get_form_edges(parent)
    row = form_edges.left.range[4]
  end

  local delta = row - child_range[2]
  indent_lines(lines, delta, {
    buf = event.buf,
  })
end

function M.indentor(event, _)
  if event.type == "slurp-forwards" or event.type == "slurp-backwards" then
    indent_slurp(event)
  else
    indent_barf(event)
  end
end

return M
