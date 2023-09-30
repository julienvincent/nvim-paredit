local api = require("nvim-paredit.api")

local M = {}

M.default_keys = {
  [">)"] = { api.slurp_forwards, "Slurp forwards" },
  [">("] = { api.barf_backwards, "Barf backwards" },

  ["<)"] = { api.barf_forwards, "Barf forwards" },
  ["<("] = { api.slurp_backwards, "Slurp backwards" },

  [">e"] = { api.drag_element_forwards, "Drag element right" },
  ["<e"] = { api.drag_element_backwards, "Drag element left" },

  [">f"] = { api.drag_form_forwards, "Drag form right" },
  ["<f"] = { api.drag_form_backwards, "Drag form left" },

  ["<localleader>o"] = { api.raise_form, "Raise form" },
  ["<localleader>O"] = { api.raise_element, "Raise element" },

  ["E"] = {
    api.move_to_next_element_tail,
    "Next element tail",
    repeatable = false,
    mode = { "n", "x", "o", "v" },
  },
  ["W"] = {
    api.move_to_next_element_head,
    "Next element head",
    repeatable = false,
    mode = { "n", "x", "o", "v" },
  },
  ["B"] = {
    api.move_to_prev_element_head,
    "Previous element head",
    repeatable = false,
    mode = { "n", "x", "o", "v" },
  },
  ["gE"] = {
    api.move_to_prev_element_tail,
    "Previous element tail",
    repeatable = false,
    mode = { "n", "x", "o", "v" },
  },

  ["("] = {
    api.move_to_prev_bracket,
    "Previous bracket in form tree",
    repeatable = false,
    mode = { "n", "x", "v" },
  },

  [")"] = {
    api.move_to_next_bracket,
    "Next bracket in form tree",
    repeatable = false,
    mode = { "n", "x", "v" },
  },


  ["af"] = {
    api.select_around_form,
    "Around form",
    repeatable = false,
    mode = { "o", "v" },
  },
  ["if"] = {
    api.select_in_form,
    "In form",
    repeatable = false,
    mode = { "o", "v" },
  },
  ["aF"] = {
    api.select_around_top_level_form,
    "Around top level form",
    repeatable = false,
    mode = { "o", "v" },
  },
  ["iF"] = {
    api.select_in_top_level_form,
    "In top level form",
    repeatable = false,
    mode = { "o", "v" },
  },

  ["ae"] = {
    api.select_element,
    "Around element",
    repeatable = false,
    mode = { "o", "v" },
  },
  ["ie"] = {
    api.select_element,
    "Element",
    repeatable = false,
    mode = { "o", "v" },
  },
}

M.defaults = {
  use_default_keys = true,
  cursor_behaviour = "auto", -- remain, follow, auto
  indent = {
    enabled = false,
    indentor = require("nvim-paredit.indentation.native").indentor,
  },
  keys = {},
}

return M
