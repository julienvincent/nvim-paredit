(module config.plugin.sx
  {autoload {ts nvim-treesitter.ts_utils
             nvim aniseed.nvim
             wk which-key
             core aniseed.core}})

(defn first [itbl] (. itbl 1))
;; lua print(vim.fn.win_getid()) 
(local get-node-text vim.treesitter.query.get_node_text)

(local lists {:fennel {:list true
                       :table true
                       :sequential_table true}
              :clojure {:set_lit true 
                        :list_lit true 
                        :str_lit true
                        :map_lit true
                        :vec_lit true}})

(defn filetype [] vim.bo.filetype)

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
  (let [[r c] (vim.api.nvim_win_get_cursor 0)]
    (ts.get_node_at_cursor 0 (vim.fn.bufnr) r c)))

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

(defn slurp-forward
  []
  (let [node (find-nearest-seq-node (cursor-node))
        lc (last-child node)
        sib (node:next_named_sibling)]
    (ts.swap_nodes lc sib (vim.fn.bufnr) false)))

(defn barf-forward
  []
  (let [node (find-nearest-seq-node (cursor-node))
        lc (last-child node)
        plc (: lc :prev_sibling)]
    (ts.swap_nodes plc lc (vim.fn.bufnr) false)))

(defn slurp-back
  []
  (let [node (find-nearest-seq-node (cursor-node))
        fc (first-child node)
        sib (node:prev_named_sibling)]
    (ts.swap_nodes fc sib (vim.fn.bufnr) false)))

(defn barf-back
  []
  (let [node (find-nearest-seq-node (cursor-node))
        fc (first-child node)
        fcr [(: fc :range)]
        nlc (: fc :next_named_sibling)
        nlcr [(: nlc :range)]
        nnlcr [(-?> nlc (: :next_named_sibling) (: :range))]]
    ;; WIP: Handle whitespace stuff
    (if (first nnlcr)
      (if (= (. nnlcr 1) (. nlcr 1))
        (tset nlcr 4 (. nnlcr 2))))
    (ts.swap_nodes fcr
                   nlcr
                   (vim.fn.bufnr) false)))

(nvim.ex.unmap :<M-t>)
(vim.keymap.set :n :<M-t>
                barf-back)

(defn slurp
  [?win-id]
  (let [win-id (or ?win-id 0)
        bufnr (nvim.win_get_buf win-id)]
    (when-let [node (find-nearest-seq-node (ts.get_node_at_cursor win-id))]
      (let [node-text (get-node-text node bufnr)
            node-wo-paren (string.sub node-text 1 -2)
            paren (string.sub node-text (length node-text))]
         (when-let [next-node (node:next_named_sibling)]
           (let [next-w-paren (.. (get-node-text next-node bufnr) paren)
                 _ (print next-w-paren)
                 r1 (ts.node_to_lsp_range node)
                 r2 (ts.node_to_lsp_range next-node)

                 edit1 {:range r1 :newText node-wo-paren}
                 edit2 {:range r2 :newText next-w-paren}]
             (vim.lsp.util.apply_text_edits [edit1 edit2] bufnr "utf-8")))))))

(comment
  (slurp 1958)

  (let [win-id 1958
        bufnr (nvim.win_get_buf win-id)]
    (when-let [node (find-nearest-seq-node (ts.get_node_at_cursor win-id))]
      (let [node-text (get-node-text node bufnr)
            node-wo-paren (string.sub node-text 1 -2)
            paren (string.sub node-text (length node-text))]
        (when-let [next-node (node:next_named_sibling)]
           (let [next-w-paren (.. (get-node-text next-node bufnr) paren)

                 r1 (ts.node_to_lsp_range node)
                 r2 (ts.node_to_lsp_range next-node)

                 edit1 {:range r1 :newText node-wo-paren}
                 edit2 {:range r2 :newText next-w-paren}]
             (vim.lsp.util.apply_text_edits [edit1 edit2] bufnr "utf-8")
             (vim.lsp.buf.format {:bufnr bufnr})))
        )))
  (local win-id 1061)
  (-> (ts.get_node_at_cursor win-id)
      (: :prev_sibling)
      ;;(: :named)
      )
  (local bufnr (nvim.win_get_buf win-id))

  (slurp win-id)
  nil)

(defn move-sexp [next-sexp-fn ?win-id]
  (let [w (or ?win-id 0)
        bufnr (nvim.win_get_buf w)
        cursor-node (-> w 
                        ts.get_node_at_cursor
                        smallest-movable-node)
        next-node (-> cursor-node
                      next-sexp-fn
                      smallest-movable-node)]
    (when next-node
      (ts.swap_nodes next-node cursor-node bufnr true)
      (ts.goto_node next-node))))

(defn move-sexp-backward [?win-id]
  (move-sexp (fn [n] (n:prev_named_sibling)) ?win-id))

(defn move-sexp-forward [?win-id]
  (move-sexp (fn [n] (n:next_named_sibling)) ?win-id))

(comment
  (move-sexp-forward 1958))

(vim.keymap.set :n "<M-s>" slurp {:desc "Slurp sexp"})
(vim.keymap.set :n "<M-p>" move-sexp-backward {:desc "Move sexp backward"})
(vim.keymap.set :n "<M-f>" move-sexp-forward {:desc "Move sexp forward"})
(nvim.ex.unmap "<M-n>")
(vim.keymap.set :n "<M-n>" (fn [_] (ts.goto_node (: (ts.get_node_at_cursor) :parent)))
               ;; (fn [wid] (let [bufnr (vim.fn.bufnr)
               ;;                            [row col] (vim.api.nvim_win_get_cursor 0)
               ;;                            tsnode (vim.treesitter.get_node_at_pos bufnr row col)]
               ;;                        (tsnode.start)))
                {:desc "Highlight parent node"})

