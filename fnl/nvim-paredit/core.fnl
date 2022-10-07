(module nvim-paredit.core
  {autoload {ts nvim-treesitter.ts_utils
             util nvim-paredit.util
             p nvim-paredit.position
             nvim aniseed.nvim
             core aniseed.core}})

(macro with-fixed-cursor-pos
  [...]
  `(let [pos# (p.get-cursor-pos)]
     ,...
     (p.set-cursor-pos pos#)))

(defn clojure-slurp-prev-sibling
  [node]
  (if (= :tagged_or_ctor_lit (-> (node:parent) (: :type)))
    (clojure-slurp-prev-sibling (node:parent))
    (util.rec-prev-named-sibling node)))

(defn slurp-prev-sibling
  [node]
  (match (util.file-type)
    :clojure (clojure-slurp-prev-sibling node)
    _ (util.rec-prev-named-sibling node)))

(defn fennel-first-node-of-opening-delimiter
  [node]
  (match (node:type)
    :quoted_list (util.first-node-of-opening-delimiter 
                   (node:parent))
    :quote (util.first-child node)
    :list (if (= :hashfn (-?> (node:parent) (: :type)))
            (util.first-node-of-opening-delimiter (node:parent))
            (util.first-child node))
    _ (util.first-child node)))

(defn clojure-first-node-of-opening-delimiter
  [node]
  (if (= :tagged_or_ctor_lit (-?> (node:parent) (: :type)))
    (clojure-first-node-of-opening-delimiter (node:parent))
    (match (node:type)
      :str_lit (clojure-first-node-of-opening-delimiter (node:parent))
      :anon_fn_lit (util.first-child node)
      :tagged_or_ctor_lit (util.first-child node)
      _ (if (= :tagged_or_ctor_lit (-?> (node:parent) (: :type)))
          (clojure-first-node-of-opening-delimiter (node:parent))
          (= :meta_lit (-?> (util.first-child node) (: :type)))
          (util.first-child node)
          (util.first-child node)))))

(defn clojure-last-node-of-opening-delimiter
  [node]
  (match (node:type)
    :tagged_or_ctor_lit (-?> node util.last-child (: :prev_sibling))
    :str_lit (-?> (node:parent) util.last-child (: :prev_sibling))
    :anon_fn_lit (-?> (util.first-child node) (: :next_sibling))
    :meta_lit (if (= :meta_lit (-?> (node:next_sibling) (: :type)))
                (clojure-last-node-of-opening-delimiter 
                  (node:next_sibling))
                (node:next_sibling))
    _ (if (= :meta_lit (-?> (util.first-child node) (: :type)))
        (clojure-last-node-of-opening-delimiter (util.first-child node))
        (util.first-child node))))

(defn fennel-last-node-of-opening-delimiter
  [node]
  (util.first-child node))

(defn first-node-of-opening-delimiter
  [node]
  (match (util.file-type)
    :fennel (fennel-first-node-of-opening-delimiter node)
    :clojure (clojure-first-node-of-opening-delimiter node)
    _ (util.first-child node)))

(defn last-node-of-opening-delimiter
  [node]
  (match (util.file-type)
    :fennel (fennel-last-node-of-opening-delimiter node)
    :clojure (clojure-last-node-of-opening-delimiter node)
    _ (util.first-child node)))

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

(defn dis_expr-node [node]
  (if (= (-?> node (: :type)) :dis_expr)
    node
    (when node (dis_expr-node (node:parent)))))

(defn disexpress-node
  []
  (let [node (util.smallest-movable-node (util.cursor-node))
        noder [(node:range)]]
    (util.insert-in-range [(. noder 1) (. noder 2)] "#_")))

(defn dedisexpress-node
  []
  (let [node (dis_expr-node (util.cursor-node))
        fc (util.first-child node)
        fcr [(fc:range)]]
    (util.insert-in-range [(. fcr 1) (. fcr 2) (. fcr 4)] "")))

(defn slurp-backward
  []
  (with-fixed-cursor-pos
    (let [node (util.find-nearest-seq-node (util.cursor-node))
          fcd (first-node-of-opening-delimiter node)
          lcd (last-node-of-opening-delimiter node)
          fcr (-> [fcd lcd] sort-node-pair node-pair->range)
          sib (slurp-prev-sibling node)
          sibr [(: sib :range)]]
      (if (= (. sibr 3) (. fcr 1))
        (tset sibr 4 (. fcr 2))
        (do (tset sibr 3 (. fcr 1))
          (tset sibr 4 (. fcr 2))))
      (ts.swap_nodes fcr sibr (util.get-bufnr) false))))

(defn barf-backward
  []
  (with-fixed-cursor-pos
    (let [node (util.find-nearest-seq-node (util.cursor-node))
          fcd (first-node-of-opening-delimiter node)
          lcd (last-node-of-opening-delimiter node)
          fcr (-> [fcd lcd] node-pair->range)
          nlc (: lcd :next_named_sibling)
          nlcr [(: nlc :range)]
          nnlcr [(-?> nlc (: :next_named_sibling) (: :range))]]
      (if (util.first nnlcr)
        (if (= (. nnlcr 1) (. nlcr 3))
          (tset nlcr 4 (. nnlcr 2))
          (do (tset nlcr 3 (. nnlcr 1))
            (tset nlcr 4 (. nnlcr 2)))))
      (ts.swap_nodes fcr nlcr (util.get-bufnr) false))))

(defn find-slurp-forward-node
  [node]
  (let [n (util.find-nearest-seq-node node)]
    (if (and n (n:next_named_sibling))
      n
      (when-let [p (-?> (n:parent) util.has-grandparent)]
        (find-slurp-forward-node p)))))

(defn slurp-forward
  []
  (with-fixed-cursor-pos
    (when-let [node (find-slurp-forward-node (util.cursor-node))]
      (let [lcd (util.last-child node)
            nns (-> (util.smallest-movable-node node)
                    (: :next_named_sibling))
            lcdr [(lcd:range)]
            nnsr [(nns:range)]]
        (when nns
          (if (= (. lcdr 3) (. nnsr 1))
            (tset nnsr 2 (. lcdr 4))
            (do (tset nnsr 1 (. lcdr 3))
              (tset nnsr 2 (. lcdr 4))))
          (ts.swap_nodes lcdr nnsr (util.get-bufnr) false))))))

(defn find-barf-forward-node
  [node]
  (when-let [n (and node (util.find-nearest-seq-node node))]
    (if (> (n:named_child_count) 0)
      n
      (when-let [p (-?> (n:parent) util.has-parent)]
        (find-barf-forward-node p)))))

(defn barf-forward
  []
  (with-fixed-cursor-pos
    (when-let [node (find-barf-forward-node (util.cursor-node))]
      (let [lc (util.last-child node)
            lcr [(: lc :range)]
            plc (: lc :prev_named_sibling)
            plcr [(: plc :range)]
            pplcr [(-?> plc (: :prev_named_sibling) (: :range))]]
        (if (util.first pplcr)
          (if (= (. plcr 1) (. pplcr 3))
            (tset plcr 2 (. pplcr 4))
            (do (tset plcr 1 (. pplcr 3))
              (tset plcr 2 (. pplcr 4)))))
        (ts.swap_nodes plcr lcr (util.get-bufnr) false)))))

(defn move-sexp [node next-sexp-fn ?win-id]
  (let [w (or ?win-id 0)
        bufnr (nvim.win_get_buf w)
        offset (p.cursor-offset-from-start node)
        next-node (-?> node
                       next-sexp-fn)]
    (when next-node
      (ts.swap_nodes node next-node bufnr true)
      (p.set-cursor-pos (p.pos+ (p.get-cursor-pos) offset)))))

(defn move-element-backward [?win-id]
  (-?> (util.cursor-node)
       util.smallest-movable-node
       util.has-parent
       (move-sexp (fn [n] (n:prev_named_sibling))
                  ?win-id)))

(defn move-element-forward [?win-id]
  (-?> (util.cursor-node)
       util.smallest-movable-node
       util.has-parent
       (move-sexp (fn [n] (n:next_named_sibling))
                  ?win-id)))

(defn move-form-forward [?win-id]
  (-?> (util.cursor-node)
       util.find-nearest-seq-node
       util.smallest-movable-node
       util.has-parent
       (move-sexp (fn [n] (n:next_named_sibling))
                  ?win-id)))

(defn move-form-backward [?win-id]
  (-?> (util.cursor-node)
       util.find-nearest-seq-node
       util.smallest-movable-node
       util.has-parent
       (move-sexp (fn [n] (n:prev_named_sibling))
                  ?win-id)))

(defn raise-node [node]
  (let [offset (p.cursor-offset-from-start node)
        nodep (node:parent)
        pos (p.nstart nodep)
        nodepr (ts.node_to_lsp_range nodep)
        nodet (vim.treesitter.get_node_text node (util.get-bufnr))]
    (util.apply-text-edits 
      [{:range nodepr :newText nodet}])
    (p.set-cursor-pos (p.pos+ pos offset))))

(defn raise-element []
  (-?> (util.cursor-node)
       util.smallest-movable-node
       util.has-grandparent
       raise-node))

(defn raise-form []
  (-?> (util.cursor-node)
       util.find-nearest-seq-node
       util.smallest-movable-node
       util.has-grandparent
       raise-node))

(defn elide-node [node]
  (let [pnode (-> node (: :prev_named_sibling))
        nnode (node:next_named_sibling)
        noder [(node:range)]
        pnoder [(-?> pnode (: :range))]
        nnoder [(-?> nnode (: :range))]
        totr (ts.node_to_lsp_range
               [(if pnode (. pnoder 3) (. noder 1))
                (if pnode (. pnoder 4) (. noder 2))
                (. noder 3)
                (. noder 4)])]
    (util.apply-text-edits 
      [{:range totr :newText ""}])
    pnode))

(defn elide-element [node]
  (-?> (util.cursor-node)
       util.has-parent
       util.smallest-movable-node
       (p.cursor-to-prev-sibling :end :no-jump)
       elide-node
       (: :parent)
       util.has-parent
       util.remove-empty-lines))

(defn elide-form [node]
  (-?> (util.cursor-node)
       util.has-parent
       util.find-nearest-seq-node
       util.smallest-movable-node
       (p.cursor-to-prev-sibling :end :no-jump)
       elide-node
       (: :parent)
       util.has-parent
       util.remove-empty-lines))

(defn fennel-find-nearest-data-node
  [node]
  (match (node:type)
    :list node
    :binding node
    :sequential_table node
    _ (when-let [p (-?> (node:parent) util.has-parent)]
        (fennel-find-nearest-data-node p))))

(defn clojure-find-nearest-data-node
  [node]
  (match (node:type)
    :vec_lit node
    :list_lit node
    _ (when-let [p (-?> (node:parent) util.has-parent)]
        (clojure-find-nearest-data-node p))))

(defn find-nearest-data-node
  [node]
  (match (util.file-type)
    :fennel (fennel-find-nearest-data-node node)
    :clojure (clojure-find-nearest-data-node node)
    _ nil))

(defn split-form []
  (when-let [node (-?> (util.cursor-node)
                       find-nearest-data-node)]
    (let [l (vim.api.nvim_get_current_line)
          pos (p.get-cursor-pos)
          opening (util.first-unnamed-child node)
          closing (util.last-unnamed-child node)
          openingt (util.get-node-text opening (util.get-bufnr))
          closingt (util.get-node-text closing (util.get-bufnr))
          spos (p.nstart opening)
          lpos (p.nend closing)]
      (when (and (p.pos< spos pos) (p.pos< pos lpos)
                 (= node (util.cursor-node)))
        (vim.api.nvim_set_current_line
          (.. (string.sub l 1 (+ (. pos 2) 1))
              closingt
              openingt
              (string.sub l (+ (. pos 2) 2))))))))
