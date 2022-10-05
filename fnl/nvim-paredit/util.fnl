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
