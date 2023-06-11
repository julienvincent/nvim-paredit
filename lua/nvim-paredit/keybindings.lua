local api = require("nvim-paredit.api")

local M = {}

local function merge(a, b)
  local result = {}
  for k, v in pairs(a) do
    result[k] = v
  end
  for k, v in pairs(b) do
    result[k] = v
  end
  return result
end

local default_keys = {
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

  ["E"] = { api.move_to_next_element, "Jump to next element tail" },
  ["B"] = { api.move_to_prev_element, "Jump to previous element head" },
}

function M.setup_keybindings(opts)
  local keys = opts.overrides
  if opts.use_defaults then
    keys = merge(default_keys, opts.overrides)
  end

  for keymap, action in pairs(keys) do
    vim.keymap.set("n", keymap, action[1], { desc = action[2] })
    vim.keymap.set("x", keymap, action[1], { desc = action[2] })
  end
end

return M
