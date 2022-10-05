(module nvim-paredit.util
  {autoload {ts nvim-treesitter.ts_utils
             nvim aniseed.nvim
             core aniseed.core}})

;; repl friendlyness
(local WIN_ID 0)
(local FILE_TYPE "clojure")

(defn first [itbl] (. itbl 1))
;; lua print(vim.fn.win_getid()) 
(local get-node-text vim.treesitter.query.get_node_text)

(local lists {:fennel {:list true
                       :table true
                       :quoted_list true
                       :sequential_table true}
              :clojure {:tagged_or_ctor_lit true
                        :set_lit true 
                        :list_lit true 
                        :str_lit true
                        :map_lit true
                        :vec_lit true
                        :anon_fn_lit true}})

(defn filetype []
  (if (not= WIN_ID 0)
    FILE_TYPE
    vim.bo.filetype))

(defn get-bufnr 
  []
  (if (not= WIN_ID 0)
    (nvim.win_get_buf WIN_ID)
    (vim.fn.bufnr)))

(defn find-nearest-seq-node
  [node]
  (if (. lists (filetype) (node:type))
    node
    (when-let [parent (node:parent)]
      (find-nearest-seq-node parent))))

(defn clojure-smallest-movable-node
  [node]
  (if (and (= (node:type) :sym_lit)
           (= (: (node:parent) :type) :meta_lit))
    (clojure-smallest-movable-node (node:parent))

    (= (node:type) :meta_lit)
    (clojure-smallest-movable-node (node:parent))

    (= (: (node:parent) :type) :tagged_or_ctor_lit)
    (clojure-smallest-movable-node (node:parent))

    node))

(defn fennel-smallest-movable-node
  [node]
  (if (and (= (node:type) :symbol) 
           (or (= :multi_symbol (: (node:parent) :type))
               (= :multi_symbol_method (: (node:parent) :type))))
    (node:parent)
    node))

(defn smallest-movable-node
  [node]
  (let [ft (filetype)]
    (if (= ft :clojure)
      (clojure-smallest-movable-node node)
      (= ft :fennel)
      (fennel-smallest-movable-node node)
      node)))

(defn cursor-node [] 
  (ts.get_node_at_cursor WIN_ID))

(defn start [node]
  (let [(r c) (unpack [(node:start)])]
    [(+ r 1) c]))

(defn end [node]
  (let [(r c) (unpack [(node:end_)])]
    [(+ r 1) c]))

(defn first-child [node]
  (let [child-count (node:child_count)]
    (when (> child-count 0)
      (node:child 0))))

(defn last-child [node]
  (let [child-count (node:child_count)]
    (when (> child-count 0)
      (node:child (- child-count 1)))))

(defn first-named-child [node]
  (let [child-count (node:named_child_count)]
    (when (> child-count 0)
      (node:named_child 0))))

(defn last-named-child [node]
  (let [child-count (node:named_child_count)]
    (when (> child-count 0)
      (node:named_child (- child-count 1)))))

(defn rec-prev-named-sibling
  [node]
  (or (node:prev_named_sibling) 
      (when (node:parent)
          (rec-prev-named-sibling (node:parent)))))

(defn rec-next-named-sibling
  [node]
  (or (node:next_named_sibling)
      (when (node:parent)
        (rec-next-named-sibling (node:parent)))))

(defn itbl [...] [...])

(defn delete-range
  [[sl sc el ec]]
  (let [ls (vim.api.nvim_buf_get_lines (get-bufnr) sl (+ el 1) true)]
    (vim.api.nvim_buf_set_lines (get-bufnr) sl (+ el 1) true
      [(.. (string.sub (. ls 1) 1 sc) (string.sub (. ls (length ls)) (+ ec 1)))])))

(defn split-lines [s]
  (icollect [k (string.gmatch s "[^\n]+")] k))

(defn insert-in-range
  [[sl sc el ec] s]
  (delete-range [sl sc el ec])
  (let [[l] (vim.api.nvim_buf_get_lines (vim.fn.bufnr) sl (+ sl 1) true)]
    (vim.api.nvim_buf_set_lines (vim.fn.bufnr) sl (+ sl 1) true
      (split-lines (.. (string.sub l 1 sc) s (string.sub l (+ ec 1)))))))

;; TODO: :program is top level for `fennel`
;;       :source is top level for `clojure`
;;       extract this...
(defn not-top-level
  [node]
  (when (and (not= (: (node:parent) :type) :program)
             (not= (: (node:parent) :type) :source)) 
    node))

(defn has-parent
  [node]
  (when (node:parent)
    node))

(defn has-grandparent
  [node]
  (when (-?> (node:parent) (: :parent))
    node))

(defn cursor-to-prev-sibling
  [node ?end ?no-jump]
  (ts.goto_node (node:prev_sibling) ?end ?no-jump)
  node)

(defn apply-text-edits
  [edits]
  (vim.lsp.util.util.apply-text-edits
    edits (get-bufnr) "utf-8"))

(defn remove-empty-lines
  [node]
  (let [noder [(node:range)]
        lines (vim.api.nvim_buf_get_lines (vim.fn.bufnr) (. noder 1) (+ (. noder 3) 1) true)
        without-empty-lines (icollect [_ k (ipairs lines)] (when (not= k "") k))]
    (vim.api.nvim_buf_set_lines (vim.fn.bufnr) (. noder 1) (+ (. noder 3) 1) true
      without-empty-lines)))

(defn get-cursor-pos
  []
  (vim.api.nvim_win_get_cursor 0))

(defn set-cursor-pos
  [pos]
  (vim.api.nvim_win_set_cursor 0 pos))
