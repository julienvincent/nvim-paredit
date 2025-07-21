## API Documentation

The core API is exposed under the `paredit.api` module

## Index

- **[Slurp / Barf](#slurp--barf)**
  - [slurp_forwards](#slurp_forwardsopts)
  - [slurp_backwards](#slurp_backwardsopts)
  - [barf_forwards](#barf_forwardsopts)
  - [barf_backwards](#barf_backwardsopts)
- **[Dragging](#dragging)**
  - [drag_element_forwards](#drag_element_forwardsopts)
  - [drag_element_backwards](#drag_element_backwardsopts)
  - [drag_pair_forwards](#drag_pair_forwards)
  - [drag_pair_backwards](#drag_pair_backwards)
  - [drag_form_forwards](#drag_form_forwards)
  - [drag_form_backwards](#drag_form_backwards)
- **[Editing](#editing)**
  - [raise_element](#raise_element)
  - [raise_form](#raise_form)
  - [delete_form](#delete_form)
  - [delete_in_form](#delete_in_form)
  - [delete_top_level_form](#delete_top_level_form)
  - [delete_in_top_level_form](#delete_in_top_level_form)
  - [delete_element](#delete_element)
- **[Motions](#motions)**
  - [move_to_next_element_tail](#move_to_next_element_tail)
  - [move_to_next_element_head](#move_to_next_element_head)
  - [move_to_prev_element_tail](#move_to_prev_element_tail)
  - [move_to_prev_element_head](#move_to_prev_element_head)
  - [move_to_parent_form_start](#move_to_parent_form_start)
  - [move_to_parent_form_end](#move_to_parent_form_end)
- **[Selections](#selections)**
  - [select_around_form](#select_around_form)
  - [select_in_form](#select_in_form)
  - [select_around_top_level_form](#select_around_top_level_form)
  - [select_in_top_level_form](#select_in_top_level_form)
  - [select_element](#select_element)
- **[Wrapping](#wrapping)**
  - [wrap_element_under_cursor](#wrap_element_under_cursorprefix-suffix)
  - [wrap_enclosing_form_under_cursor](#wrap_enclosing_form_under_cursor)
  - [unwrap_form_under_cursor](#unwrap_form_under_cursor)
- **[Cursor Manipulation](#cursor-manipulation)**
  - [place_cursor](#place_cursorrange_or_node-opts)

---

## **[Slurp / Barf](#slurp--barf)**

##### `SlurpBarfOpts`

```lua
{
  cursor_behaviour = "auto", -- remain, follow, auto
  indent = {
    enabled = false,
    indentor = require("nvim-paredit.indentation.native").indentor,
  },
}
```

#### `slurp_forwards([opts])`

Expands the current form by pulling in the next expression into the form.

- **`opts`** - see **[SlurpBarfOpts](#SlurpBarfOpts)**

---

#### `slurp_backwards([opts])`

Expands the current form by pulling the previous expression into the form.

- **`opts`** - see **[SlurpBarfOpts](#SlurpBarfOpts)**

---

#### `barf_forwards([opts])`

Removes the last expression from the current form, pushing it outwards.

- **`opts`** - see **[SlurpBarfOpts](#SlurpBarfOpts)**

---

#### `barf_backwards([opts])`

Removes the first expression from the current form, pushing it outwards.

- **`opts`** - see **[SlurpBarfOpts](#SlurpBarfOpts)**

---

## **[Dragging](#dragging)**

##### `ElementDragOpts`

```lua
{
  dragging = {
    enable_auto_drag = true
  }
}
```

#### `drag_element_forwards([opts])`

Moves the current element or pair forwards within its form.

- **`opts`** - see **[ElementDragOpts](#ElementDragOpts)**

---

#### `drag_element_backwards([opts])`

Moves the current element or pair backwards within its form.

- **`opts`** - see **[ElementDragOpts](#ElementDragOpts)**

---

#### `drag_pair_forwards()`

Moves the current pair of elements forwards within its form.

**Inputs:**

- `pair`: (Optional) The pair of elements to drag forwards. Defaults to the pair at the current cursor position.

---

#### `drag_pair_backwards()`

Moves the current pair of elements backwards within its form.

**Inputs:**

- `pair`: (Optional) The pair of elements to drag backwards. Defaults to the pair at the current cursor position.

---

#### `drag_form_forwards()`

Moves the current form forwards within its parent form.

---

#### `drag_form_backwards()`

Moves the current form backwards within its parent form.

---

## **[Editing](#editing)**

#### `raise_element()`

Raises the current element, removing it from its enclosing form.

---

#### `raise_form()`

Raises the current form, removing it from its enclosing form.

---

#### `delete_form()`

Deletes the current form.

---

#### `delete_in_form()`

Deletes the content inside the current form without removing the form itself.

---

#### `delete_top_level_form()`

Deletes the current top-level form.

---

#### `delete_in_top_level_form()`

Deletes the content inside the current top-level form without removing the form itself.

---

#### `delete_element()`

Deletes the current element.

---

### **[Motions](#motions)**

#### `move_to_next_element_tail()`

Moves the cursor to the tail of the next element in the form.

---

#### `move_to_next_element_head()`

Moves the cursor to the head of the next element in the form.

---

#### `move_to_prev_element_head()`

Moves the cursor to the head of the previous element in the form.

---

#### `move_to_prev_element_tail()`

Moves the cursor to the tail of the previous element in the form.

---

#### `move_to_parent_form_start()`

Moves the cursor to the start of the parent form.

---

#### `move_to_parent_form_end()`

Moves the cursor to the end of the parent form.

---

#### `move_to_top_level_form_head()`

Moves the cursor to the head of the top level form.

---

### **[Selections](#selections)**

#### `select_around_form()`

Selects the form surrounding the cursor, including the enclosing delimiters.

---

#### `select_in_form()`

Selects the content inside the form surrounding the cursor, excluding the enclosing delimiters.

---

#### `select_around_top_level_form()`

Selects the top-level form surrounding the cursor, including the enclosing delimiters.

---

#### `select_in_top_level_form()`

Selects the content inside the top-level form surrounding the cursor, excluding the enclosing delimiters.

---

#### `select_element()`

Selects the current element under the cursor.

---

### **[Wrapping](#wrapping)**

#### `wrap_element_under_cursor(prefix, suffix)`

Wraps the element under the cursor with a prefix and suffix.

- `prefix`: string
- `suffix`: string

Returns The wrapped `TSNode`.

---

#### `wrap_enclosing_form_under_cursor()`

Wraps the enclosing form under the cursor with a prefix and suffix.

- `prefix`: string
- `suffix`: string

Returns The wrapped `TSNode`.

#### `unwrap_form_under_cursor()`

Unwraps the nearest form under the cursor. This is called splice in other paredit implementations.

---

### **[Cursor Manipulation](#cursor-manipulation)**

These APIs are exposed from `paredit.api.cursor`.

#### `place_cursor(range_or_node, opts)`

Places the cursor at a specific position within a `TSNode`.

- `node`: The `TSNode` to operate within
- `opts` table
  - `placement`: (Optional) The position relative to the node. Can be `left_edge`, `inner_start`, `inner_end`, or
    `right_edge`. Defaults to `left_edge`.
  - `mode`: (Optional) The mode for cursor placement. Currently only `insert` is supported, defaults to `normal`.
