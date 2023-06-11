local slurping = require("nvim-paredit.slurping")
local barfing = require("nvim-paredit.barfing")
local dragging = require("nvim-paredit.dragging")
local raising = require("nvim-paredit.raising")
local motions = require("nvim-paredit.motions")

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

  move_to_next_element = motions.move_to_next_element,
  move_to_prev_element = motions.move_to_prev_element,
}

return M
