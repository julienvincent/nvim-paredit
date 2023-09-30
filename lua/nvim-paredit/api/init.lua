local slurping = require("nvim-paredit.api.slurping")
local barfing = require("nvim-paredit.api.barfing")
local dragging = require("nvim-paredit.api.dragging")
local raising = require("nvim-paredit.api.raising")
local motions = require("nvim-paredit.api.motions")
local selections = require("nvim-paredit.api.selections")
local deletions = require("nvim-paredit.api.deletions")
local common = require("nvim-paredit.utils.common")

local M = {
  slurp_forwards = slurping.slurp_forwards,
  slurp_backwards = slurping.slurp_backwards,
  barf_forwards = barfing.barf_forwards,
  barf_backwards = barfing.barf_backwards,

  drag_element_forwards = dragging.drag_element_forwards,
  drag_element_backwards = dragging.drag_element_backwards,
  drag_form_forwards = dragging.drag_form_forwards,
  drag_form_backwards = dragging.drag_form_backwards,

  raise_form = raising.raise_form,
  raise_element = raising.raise_element,

  -- TODO: remove deprecated code in next versions
  move_to_next_element = common.deprecate(motions.move_to_next_element_tail, "use `api.move_to_next_element_tail`"),
  move_to_next_element_tail = motions.move_to_next_element_tail,
  move_to_next_element_head = motions.move_to_next_element_head,

  -- TODO: remove deprecated code in next versions
  move_to_prev_element = common.deprecate(motions.move_to_prev_element_head, "use `api.move_to_prev_element_head`"),
  move_to_prev_element_head = motions.move_to_prev_element_head,
  move_to_prev_element_tail = motions.move_to_prev_element_tail,
  move_to_prev_bracket = motions.move_to_parent_form_start,
  move_to_next_bracket = motions.move_to_parent_form_end,

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
}

return M
