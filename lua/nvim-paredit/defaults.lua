local api = require("nvim-paredit.api")

local M = {}

M.default_keys = {
  ["<localleader>@"] = { api.unwrap_form_under_cursor, "Splice sexp" },

  [">)"] = { api.slurp_forwards, "Slurp forwards" },
  [">("] = { api.barf_backwards, "Barf backwards" },

  ["<)"] = { api.barf_forwards, "Barf forwards" },
  ["<("] = { api.slurp_backwards, "Slurp backwards" },

  [">e"] = { api.drag_element_forwards, "Drag element right" },
  ["<e"] = { api.drag_element_backwards, "Drag element left" },

  [">p"] = { api.drag_pair_forwards, "Drag element pairs right" },
  ["<p"] = { api.drag_pair_backwards, "Drag element pairs left" },

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
    api.move_to_parent_form_start,
    "Parent form's head",
    repeatable = false,
    mode = { "n", "x", "v" },
  },

  [")"] = {
    api.move_to_parent_form_end,
    "Parent form's tail",
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
    api.select_around_element,
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
  dragging = {
    -- If set to `true` paredit will attempt to infer if an element being
    -- dragged is part of a 'paired' form like as a map. If so then the element
    -- will be dragged along with it's pair.
    auto_drag_pairs = true,
  },
  indent = {
    enabled = false,
    indentor = require("nvim-paredit.indentation.native").indentor,
  },
  filetypes = { "clojure", "fennel", "scheme", "lisp" },
  languages = {
    clojure = {
      whitespace_chars = { " ", "," },
    },
    fennel = {
      whitespace_chars = { " ", "," },
    },
  },
  keys = {},
}

return M
