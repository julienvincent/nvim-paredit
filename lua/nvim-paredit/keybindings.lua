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

-- This is a hack to enable dot-repeat for fn keymaps.
--
-- For more information on how this works, see:
-- https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
--
-- For this to work in a keymap, make sure `expr = true` is defined:
--  vim.keymap.set("n", "lhs", with_repeat(function() end), { expr = true })
function M.with_repeat(fn)
  return function()
    _G.NVIM_PAREDIT_REPEAT_FN = function()
      fn()
    end
    vim.go.operatorfunc = "v:lua.NVIM_PAREDIT_REPEAT_FN"
    return "g@l"
  end
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
    local repeatable = true
    if type(action.repeatable) == "boolean" then
      repeatable = action.repeatable
    end

    local fn = action[1]
    if repeatable then
      fn = M.with_repeat(fn)
    end

    vim.keymap.set({ "n", "x" }, keymap, fn, {
      desc = action[2],
      expr = true,
    })
  end
end

return M
