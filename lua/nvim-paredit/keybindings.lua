local api = require("nvim-paredit.api")

local M = {}

function merge(a, b)
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
  [">)"] = { api.slurpForwards, "Slurp forwards" },
  [">("] = { api.slurpBackwards, "Slurp backwards" },

  ["<)"] = { api.slurpForwards, "Barf forwards" },
  ["<("] = { api.slurpBackwards, "Barf backwards" },

  [">e"] = { api.dragElementForwards, "Drag element right" },
  ["<e"] = { api.dragElementBackwards, "Drag element left" },

  [">f"] = { api.dragFormForwards, "Drag form right" },
  ["<f"] = { api.dragFormBackwards, "Drag form left" },

  ["<localleader>o"] = { api.raiseForm, "Raise form" },
  ["<localleader>O"] = { api.raiseElement, "Raise element" },

  ["E"] = { api.moveToNextElement, "Jump to next element tail" },
  ["B"] = { api.moveToPrevElement, "Jump to previous element head" },
}

function M.setupKeybindings(opts)
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
