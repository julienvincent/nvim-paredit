local slurping = require("nvim-paredit.api.slurping")
local barfing = require("nvim-paredit.api.barfing")
local dragging = require("nvim-paredit.api.dragging")
local raising = require("nvim-paredit.api.raising")
local motions = require("nvim-paredit.api.motions")
local selections = require("nvim-paredit.api.selections")
local deletions = require("nvim-paredit.api.deletions")
local wrap = require("nvim-paredit.api.wrap")
local unwrap = require("nvim-paredit.api.unwrap")

local M = {
  slurp_forwards = slurping.slurp_forwards,
  slurp_backwards = slurping.slurp_backwards,
  barf_forwards = barfing.barf_forwards,
  barf_backwards = barfing.barf_backwards,

  drag_element_forwards = dragging.drag_element_forwards,
  drag_element_backwards = dragging.drag_element_backwards,

  drag_pair_forwards = dragging.drag_pair_forwards,
  drag_pair_backwards = dragging.drag_pair_backwards,

  drag_form_forwards = dragging.drag_form_forwards,
  drag_form_backwards = dragging.drag_form_backwards,

  raise_form = raising.raise_form,
  raise_element = raising.raise_element,

  move_to_next_element_tail = motions.move_to_next_element_tail,
  move_to_next_element_head = motions.move_to_next_element_head,

  move_to_prev_element_head = motions.move_to_prev_element_head,
  move_to_prev_element_tail = motions.move_to_prev_element_tail,

  move_to_parent_form_start = motions.move_to_parent_form_start,
  move_to_parent_form_end = motions.move_to_parent_form_end,
  move_to_top_level_form_head = motions.move_to_top_level_form_head,
  flow_form_next_head = motions.flow_form_next_head,
  flow_form_prev_head = motions.flow_form_prev_head,

  select_around_form = selections.select_around_form,
  select_in_form = selections.select_in_form,
  select_around_top_level_form = selections.select_around_top_level_form,
  select_in_top_level_form = selections.select_in_top_level_form,
  select_element = selections.select_element,

  delete_form = deletions.delete_form,
  delete_in_form = deletions.delete_in_form,
  delete_top_level_form = deletions.delete_top_level_form,
  delete_in_top_level_form = deletions.delete_in_top_level_form,
  delete_element = deletions.delete_element,

  wrap_element_under_cursor = wrap.wrap_element_under_cursor,
  wrap_enclosing_form_under_cursor = wrap.wrap_enclosing_form_under_cursor,
  unwrap_form_under_cursor = unwrap.unwrap_form_under_cursor,
}

return M
