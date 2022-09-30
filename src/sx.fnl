(module config.plugin.sx
  {autoload {ts nvim-treesitter.ts_utils
             nvim aniseed.nvim
             wk which-key
             core aniseed.core}})

;; lua print(vim.fn.win_getid()) 
(local get-node-text vim.treesitter.query.get_node_text)

(local lists {:set_lit true 
              :list_lit true 
              :str_lit true
              :map_lit true
              :vec_lit true})

(defn find-nearest-seq-node
  [node]
  (if (. lists (node:type))
    node
    (when-let [parent (node:parent)]
      (find-nearest-seq-node parent))))

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
        cursor-node (ts.get_node_at_cursor w)
        next-node (next-sexp-fn cursor-node)]
    (when next-node
      (ts.swap_nodes next-node cursor-node bufnr true))))

(defn move-sexp-backward [?win-id]
  (move-sexp (fn [n] (n:prev_named_sibling)) ?win-id))

(defn move-sexp-forward [?win-id]
  (move-sexp (fn [n] (n:next_named_sibling)) ?win-id))

(comment
  (move-sexp-forward 1958))

(vim.keymap.set :n "<M-l>" slurp {:desc "Slurp sexp"})
(vim.keymap.set :n "<M-.>" move-sexp-forward {:desc "Move sexp forward"})
(vim.keymap.set :n "<M-,>" move-sexp-backward {:desc "Move sexp backward"})

