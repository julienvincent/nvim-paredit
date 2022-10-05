(module config.plugin.sx
  {autoload {ts nvim-treesitter.ts_utils
             nvim aniseed.nvim
             wk which-key
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
              :clojure {:set_lit true 
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

(defn rec_prev_named_sibling
  [node]
  (or (node:prev_named_sibling) 
      (when (node:parent)
          (rec_prev_named_sibling (node:parent)))))

(defn clojure-slurp-prev-sibling
  [node]
  (if (= :tagged_or_ctor_lit (-> (node:parent) (: :type)))
    (rec_prev_named_sibling (node:parent))
    (rec_prev_named_sibling node)))

(defn slurp-prev-sibing
  [node]
  (match (filetype)
    :clojure (clojure-slurp-prev-sibling node)
    _ (rec_prev_named_sibling node)))

(defn rec_next_named_sibling
  [node]
  (or (node:next_named_sibling)
      (when (node:parent)
        (rec_next_named_sibling (node:parent)))))


(defn fennel-first-node-of-opening-delimiter
  [node]
  (match (node:type)
    :quoted_list (first-node-of-opening-delimiter 
                   (node:parent))
    :quote (first-child node)
    :list (if (= :hashfn (-?> (node:parent) (: :type)))
            (first-node-of-opening-delimiter (node:parent))
            (first-child node))
    _ (first-child node)))

(defn clojure-first-node-of-opening-delimiter
  [node]
  (if (= :tagged_or_ctor_lit (-?> (node:parent) (: :type)))
    (clojure-first-node-of-opening-delimiter (node:parent))
    (match (node:type)
      :anon_fn_lit (first-child node)
      :tagged_or_ctor_lit (first-child node)
      _ (if (= :tagged_or_ctor_lit (-?> (node:parent) (: :type)))
          (clojure-first-node-of-opening-delimiter (node:parent))
          (= :meta_lit (-?> (first-child node) (: :type)))
          (first-child node)
          (first-child node)))))

(defn clojure-last-node-of-opening-delimiter
  [node]
  (match (node:type)
    :anon_fn_lit (-?> (first-child node) (: :next_sibling))
    :meta_lit (if (= :meta_lit (-?> (node:next_sibling) (: :type)))
                (clojure-last-node-of-opening-delimiter 
                  (node:next_sibling))
                (node:next_sibling))
    _ (if (= :meta_lit (-?> (first-child node) (: :type)))
        (clojure-last-node-of-opening-delimiter (first-child node))
        (first-child node))))

(defn fennel-last-node-of-opening-delimiter
  [node]
  (first-child node))

(defn first-node-of-opening-delimiter
  [node]
  (match (filetype)
    :fennel (fennel-first-node-of-opening-delimiter node)
    :clojure (clojure-first-node-of-opening-delimiter node)
    _ (first-child node)))

(defn last-node-of-opening-delimiter
  [node]
  (match (filetype)
    :fennel (fennel-last-node-of-opening-delimiter node)
    :clojure (clojure-last-node-of-opening-delimiter node)
    _ (first-child node)))

(defn sort-node-pair
  [[node1 node2]]
  (let [nr1 [(node1:range)] nr2 [(node2:range)]]
    (if (< (. nr1 1) (. nr2 1))
      [node1 node2]
      (< (. nr2 1) (. nr1 1))
      [node2 node1]
      (< (. nr1 2) (. nr2 2))
      [node1 node2]
      [node2 node1])))

(defn node-pair->range
  [[node1 node2]]
  (let [nr1 [(node1:range)] nr2 [(node2:range)]]
    [(. nr1 1) (. nr1 2) (. nr2 3) (. nr2 4)]))

;; (defn get-range
;;   [[sl sc el ec]]
;;   (let [[l] (vim.api.nvim_buf_get_lines (vim.fn.bufnr) sl (+ el 1) true)]
;;     (string.sub l (+ sc 1) ec)))
;; 
;; (defn set-range
;;   [[sl sc el ec] s]
;;   (let [[l] (vim.api.nvim_buf_get_lines (vim.fn.bufnr) sl (+ el 1) true)]
;;     (vim.api.nvim_buf_set_lines 
;;       (vim.fn.bufnr)
;;       sl (+ el 1) true
;;       [(.. (string.sub l 1 sc)
;;            s
;;            (string.sub l (+ ec 1)))])))

;; (defn prepend-with
;;   [[sl sc el ec] s]
;;   (let [[l] (vim.api.nvim_buf_get_lines (vim.fn.bufnr) sl (+ sl 1) true)]
;;     (vim.api.nvim_buf_set_lines (vim.fn.bufnr) sl (+ sl 1) true
;;       [(.. s l)])))
;; 
;; (defn subtend-from
;;   [[sl sc el ec] s]
;;   (let [[l] (vim.api.nvim_buf_get_lines (vim.fn.bufnr) sl (+ sl 1) true)]
;;     (vim.api.nvim_buf_set_lines (vim.fn.bufnr) sl (+ sl 1) true
;;       [(string.sub l (+ (length s) 1))])))
;; 
;; (defn insert-in-range
;;   [[sl sc] s]
;;   (let [[l] (vim.api.nvim_buf_get_lines (vim.fn.bufnr) sl (+ sl 1) true)]
;;     (vim.api.nvim_buf_set_lines (vim.fn.bufnr) sl (+ sl 1) true
;;       [(.. (string.sub l 1 sc) s (string.sub l (+ sc 1)))])))
;; 
;; (defn exise-from-range
;;   [sl [sc ec]]
;;   (let [[l] (vim.api.nvim_buf_get_lines (vim.fn.bufnr) sl (+ sl 1) true)]
;;     (vim.api.nvim_buf_set_lines (vim.fn.bufnr) sl (+ sl 1) true
;;       [(.. (string.sub l 1 sc) (string.sub l (+ ec 1)))])))

(defn slurp-back-2
  []
  (let [node (find-nearest-seq-node (cursor-node))
        fcd (first-node-of-opening-delimiter node)
        lcd (last-node-of-opening-delimiter node)
        fcr (-> [fcd lcd] sort-node-pair node-pair->range)
        sib (slurp-prev-sibing node)
        sibr [(: sib :range)]
        s (get-range fcr)]
    (if (= (. sibr 3) (. fcr 1))
      (tset sibr 4 (. fcr 2))
      (do (tset sibr 3 (. fcr 1))
        (tset sibr 4 (. fcr 2))))
    (ts.swap_nodes fcr sibr (get-bufnr) false)))

(defn barf-back-2
  []
  (let [node (find-nearest-seq-node (cursor-node))
        fcd (first-node-of-opening-delimiter node)
        lcd (last-node-of-opening-delimiter node)
        fcr (-> [fcd lcd] sort-node-pair node-pair->range)
        nlc (: lcd :next_named_sibling)
        nlcr [(: nlc :range)]
        nnlcr [(-?> nlc (: :next_named_sibling) (: :range))]]
    (if (first nnlcr)
      (if (= (. nnlcr 1) (. nlcr 3))
        (tset nlcr 4 (. nnlcr 2))
        (do (tset nlcr 3 (. nnlcr 1))
          (tset nlcr 4 (. nnlcr 2)))))
    (ts.swap_nodes fcr nlcr (get-bufnr) false)))

(vim.keymap.set :n :<M-t> barf-back-2)

(defn default-opening-delimiter-range
  [node]
  [(-?> node first-child (: :range))])

(defn include-parent-opening-delimiter
  [node]
  (let [p (node:parent)
        pfcr [(: (first-child (node:parent)) :range)]
        fcr [(: (first-child node) :range)]]
    [(. pfcr 1) (. pfcr 2) (. fcr 3) (. fcr 4)]))

(defn fennel-opening-delimiter-range
  [node]
  (match (node:type)
    :quoted_list (include-parent-opening-delimiter node)
    :list (if (= (: (node:parent) :type) :hashfn)
            (include-parent-opening-delimiter node)
            (default-opening-delimiter-range node))
    _ (default-opening-delimiter-range node)))

(defn clojure-opening-delimiter-range
  [node]
  (match (node:type)
    :anon_fn_lit (let [fc (first-child node)
                       fcr [(fc:range)]
                       scr [(: (fc:next_sibling node) :range)]]
                   [(. fcr 1) (. fcr 2) (. scr 3) (. scr 4)])
    :list_lit (if (= :quoting_lit (-?> (node:parent) (: :type)))
                (include-parent-opening-delimiter node)
                (default-opening-delimiter-range node))
    _ (default-opening-delimiter-range node)))

(defn opening-delimiter-range
  [node]
  (match (filetype)
    :fennel (fennel-opening-delimiter-range node)
    :clojure (clojure-opening-delimiter-range node)
    _ (default-opening-delimiter-range node)))

(defn slurp-forward
  []
  (let [node (find-nearest-seq-node (cursor-node))
        lc (last-child node)
        lcr [(: lc :range)]
        sib (rec_next_named_sibling node)
        sibr [(: sib :range)]]
    (if (= (. lcr 3) (. sibr 1))
      (tset sibr 2 (. lcr 4))
      (do (tset sibr 1 (. lcr 3))
        (tset sibr 2 (. lcr 4))))
    (ts.swap_nodes lcr sibr (get-bufnr) false)))

(defn barf-forward
  []
  (let [node (find-nearest-seq-node (cursor-node))
        lc (last-child node)
        lcr [(: lc :range)]
        plc (: lc :prev_named_sibling)
        plcr [(: plc :range)]
        pplcr [(-?> plc (: :prev_named_sibling) (: :range))]]
    (if (first pplcr)
      (if (= (. plcr 1) (. pplcr 3))
        (tset plcr 2 (. pplcr 4))
        (do (tset plcr 1 (. pplcr 3))
          (tset plcr 2 (. pplcr 4)))))
    (ts.swap_nodes plcr lcr (get-bufnr) false)))

(comment
  (local n (cursor-node))
  (start n)
  (end n)
  (first-child n)
  (default-opening-delimiter-range n)
  (slurp-forward)
  (barf-forward)
  (barf-back)
  (slurp-back)
  nil)

(defn slurp-back
  []
  (let [node (find-nearest-seq-node (cursor-node))
        fc (first-child node)
        fcr (opening-delimiter-range node)
        sib (rec_prev_named_sibling node)
        sibr [(: sib :range)]]
    (if (= (. sibr 3) (. fcr 1))
      (tset sibr 4 (. fcr 2))
      (do (tset sibr 3 (. fcr 1))
        (tset sibr 4 (. fcr 2))))
    (ts.swap_nodes fcr sibr (get-bufnr) false)))

(defn barf-back
  []
  (let [node (find-nearest-seq-node (cursor-node))
        fc (first-child node)
        fcr (opening-delimiter-range node)
        nlc (: fc :next_named_sibling)
        nlcr [(: nlc :range)]
        nnlcr [(-?> nlc (: :next_named_sibling) (: :range))]]
    (if (first nnlcr)
      (if (= (. nnlcr 1) (. nlcr 3))
        (tset nlcr 4 (. nnlcr 2))
        (do (tset nlcr 3 (. nnlcr 1))
          (tset nlcr 4 (. nnlcr 2)))))
    (ts.swap_nodes fcr nlcr (get-bufnr) false)))

;;(nvim.ex.unmap :<M-t>)
(vim.keymap.set :n :<M-t> slurp-back)

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
