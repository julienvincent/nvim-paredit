local slurping = require("nvim-paredit.slurping")
local barfing = require("nvim-paredit.barfing")
local dragging = require("nvim-paredit.dragging")
local raising = require("nvim-paredit.raising")

local M = {
  slurpForwards = slurping.slurpForwards,
  slurpBackwards = slurping.slurpBackwards,
  barfForwards = barfing.barfForwards,
  barfBackwards = barfing.barfBackwards,

  dragElementForwards = dragging.dragElementForwards,
  dragElementBackwards = dragging.dragElementBackwards,
  dragFormForwards = dragging.dragFormForwards,
  dragFormBackwards = dragging.dragFormBackwards,

  raiseForm = raising.raiseForm,
  raiseElement = raising.raiseElement,
}

return M
