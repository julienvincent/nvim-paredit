# Recipes

### Lsp Indentation

Below is a reference implementation for using `vim.lsp.buf.format` to replace the native indent implementation. This
implementation won't be nearly as performant, but it will be more correct.

```lua
local function lsp_indent(event, opts)
  local traversal = require("nvim-paredit.utils.traversal")
  local utils = require("nvim-paredit.indentation.utils")
  local langs = require("nvim-paredit.lang")

  local lang = langs.get_language_api()

  local parent = event.parent

  local child
  if event.type == "slurp-forwards" then
    child = parent:named_child(parent:named_child_count() - 1)
  elseif event.type == "slurp-backwards" then
    child = parent:named_child(1)
  elseif event.type == "barf-forwards" then
    child = traversal.get_next_sibling_ignoring_comments(event.parent, { lang = lang })
  elseif event.type == "barf-backwards" then
    child = event.parent
  else
    return
  end

  local child_range = { child:range() }
  local lines = utils.find_affected_lines(child, utils.get_node_line_range(child_range))

  vim.lsp.buf.format({
    bufnr = opts.buf or 0,
    range = {
      ["start"] = { lines[1] + 1, 0 },
      ["end"] = { lines[#lines] + 1, 0 },
    },
  })
end

local child_range = { child:range() }
local lines = utils.find_affected_lines(child, utils.get_node_line_range(child_range))

vim.lsp.buf.format({
  bufnr = opts.buf or 0,
  range = {
    ["start"] = { lines[1] + 1, 0 },
    ["end"] = { lines[#lines] + 1, 0 },
  },
})
end

require("nvim-paredit").setup({
  indent = {
    enabled = true,
    indentor = lsp_indent,
  },
})
```

### Wrap form (head/tail)

This is to mimic the behaviour from `vim-sexp`

Require API module:

```lua
local paredit = require("nvim-paredit")
```

Add following keybindings to config:

```lua
["<localleader>w"] = {
  function()
    -- place cursor and set mode to `insert`
    paredit.cursor.place_cursor(
      -- wrap element under cursor with `( ` and `)`
      paredit.wrap.wrap_element_under_cursor("( ", ")"),
      -- cursor placement opts
      { placement = "inner_start", mode = "insert" }
    )
  end,
  "Wrap element insert head",
},

["<localleader>W"] = {
  function()
    paredit.cursor.place_cursor(
      paredit.wrap.wrap_element_under_cursor("(", ")"),
      { placement = "inner_end", mode = "insert" }
    )
  end,
  "Wrap element insert tail",
},

-- same as above but for enclosing form
["<localleader>i"] = {
  function()
    paredit.cursor.place_cursor(
      paredit.wrap.wrap_enclosing_form_under_cursor("( ", ")"),
      { placement = "inner_start", mode = "insert" }
    )
  end,
  "Wrap form insert head",
},

["<localleader>I"] = {
  function()
    paredit.cursor.place_cursor(
      paredit.wrap.wrap_enclosing_form_under_cursor("(", ")"),
      { placement = "inner_end", mode = "insert" }
    )
  end,
  "Wrap form insert tail",
}
```

Same approach can be used for other `vim-sexp` keybindings (e.g. `<localleader>e[`) with cursor placement or without.

### Custom Macro Pairwise Dragging

This is an example of how you can add pairwise dragging support for the following custom Clojure macro:

```clojure
(defmacro my-custom-bindings [bindings & body]
  ...)

(my-custom-bindings [a 1
                     b 2]
  (println a b))
```

Create a new file under `queries/clojure/paredit/pairs.scm` in your neovim configuration directory and add the following
treesitter query:

```scm
;; extends

(list_lit
  (sym_lit) @fn-name
  (vec_lit
    (_) @pair)
  (#eq? @fn-name "my-custom-bindings"))
```

That's it!
