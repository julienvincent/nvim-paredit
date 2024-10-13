# Language Queries

Nvim-paredit works by executing treesitter queries over the nodes it is operating over and extracting known capture
groups. It can then use these capture groups to understand the AST in a grammar agnostic manner.

There are two query files that nvim-paredit reads:

### - `queries/<language>/paredit/forms.scm`

The `forms.scm` query file is always executed and is used for collecting general structural information about the nodes
being operated on.

It needs to contain the following captures:

#### `@form`

This should be appended to any node that can be considered a 'form'. A form would be defined as an s-exp that contains
child nodes. An example from Clojure would be:

```clojure
{} ;; a map
[] ;; a vector
() ;; a list
#{} ;; a set
;; etc
```

#### `@comment`

This should be appended to any nodes that are considered comments. In general nvim-paredit operations explicitly skip
over or ignore comment nodes.

This is optional if your grammar considers comments as `:extra()` or if your comment nodes `:type()` is explicitly equal
to `"comment"`.

---

Here is a partial example for Clojure:

```scm
;; queries/clojure/paredit/forms.scm

(list_lit) @form
(map_lit) @form

(comment) @comment
```

See the [source file](../queries/clojure/paredit/forms.scm) for a full example.

---

### - `queries/<language>/paredit/pairs.scm`

The `pairs.scm` is only executed when performing pairwise dragging and is used to determine which elements within a form
are 'paired'.

It should contain the following captures:

#### `@pair`

This should be appended to elements within a form that are considered 'paired'. These elements are used to identify
pairs when performing [pairwise dragging](../README.md#pairwise-dragging).

---

Here is a partial example for Clojure:

```scm
;; queries/clojure/paredit/pairs.scm

(list_lit 
  (sym_lit) @fn-name
  (vec_lit
    (_) @pair)
  (#any-of? @fn-name "let" "loop" "binding" "with-open" "with-redefs"))
```

See the [source file](../queries/clojure/paredit/pairs.scm) for a full example.

---

## Developing

These query files described above can be added locally to your neovim config queries directory, to a queries directory
in a new plugin, or within the queries directory of nvim-paredit.

If you add these query files to your own neovim config and want to extend or modify the existing queries for a supported
language make sure to add the `;; extends` directive to the top of the file. If you don't specify this then any queries
defined by nvim-paredit will be overridden.

Only the `forms.scm` queries file is required for adding language support. The `pairs.scm` file is optional and only
needed to augment the implementation with [pairwise dragging](../README.md#pairwise-dragging). If this query file cannot
be found then the default dragging behaviour will continue to work just fine.

> [!NOTE]
>
> If you add queries for a new language you will also need to configure the `filetypes` table in nvim-paredit during
> setup.
>
> Paredit only runs on buffers included in the `filetypes` table!

```lua
local paredit = require("nvim-paredit")
paredit.setup({
  filetypes = { "clojure", ..., "<your-new-language>" }
})
```
