# Language Extension Spec

> [!WARNING]
>
> This API is considered **very alpha** and may change without warning

### API

```lua
local language_extension = {
  -- Should return the 'root' of the given Treesitter node. For example:
  -- The node at cursor in the below example is `()` or 'list_lit':
  --   '(|)
  -- But the node root is `'()` or 'quoting_lit'
  get_node_root = function(node) end,
  -- This is the inverse of `get_node_root` for forms and should find the inner node for which
  -- the forms elements are direct children.
  --
  -- For example given the node `'()` or 'quoting_lit', this function should return `()` or 'list_lit'.
  unwrap_form = function(node) end,
  -- Accepts a Treesitter node and should return true or false depending on whether the given node
  -- can be considered a 'form'
  node_is_form = function(node) end,
  -- Accepts a Treesitter node and should return true or false depending on whether the given node
  -- can be considered a 'comment'
  node_is_comment = function(node) end,
  -- Accepts a Treesitter node representing a form and should return the 'edges' of the node. This
  -- includes the node text and the range covered by the node
  get_form_edges = function(node)
    return {
      left = { text = "#{", range = { 0, 0, 0, 2 } },
      right = { text = "}", range = { 0, 5, 0, 6 } },
    }
  end,
}
```

See also [the clojure implementation](../lua/nvim-paredit/lang/clojure.lua) for a good reference.

## Registration

Extensions can either be registered as config when calling `setup` or by calling the `add_language_extension` API before
the setup. The latter would be the recommended approach for extension plugin authors.

```lua
require("nvim-paredit").setup({
  extensions = {
    commonlisp = { ... },
  },
})
```

```lua
require("nvim-paredit").extension.add_language_extension("commonlisp", { ... }).
```
