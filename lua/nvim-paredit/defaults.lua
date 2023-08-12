local api = require("nvim-paredit.api")

local M = {}

M.default_keys = {
  [">)"] = { api.slurp_forwards, "Slurp forwards" },
  [">("] = { api.slurp_backwards, "Slurp backwards" },

  ["<)"] = { api.barf_forwards, "Barf forwards" },
  ["<("] = { api.barf_backwards, "Barf backwards" },

  [">e"] = { api.drag_element_forwards, "Drag element right" },
  ["<e"] = { api.drag_element_backwards, "Drag element left" },

  [">f"] = { api.drag_form_forwards, "Drag form right" },
  ["<f"] = { api.drag_form_backwards, "Drag form left" },

  ["<localleader>o"] = { api.raise_form, "Raise form" },
  ["<localleader>O"] = { api.raise_element, "Raise element" },

  ["E"] = {
    api.move_to_next_element,
    "Next element tail",
    repeatable = false,
    mode = { "n", "x", "o", "v" },
  },
  ["B"] = {
    api.move_to_prev_element,
    "Previous element head",
    repeatable = false,
    mode = { "n", "x", "o", "v" },
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
}

M.defaults = {
  use_default_keys = true,
  cursor_behaviour = "auto", -- remain, follow, auto
  keys = {},
}

return M
