(module nvim-paredit.position
  {autoload {ts nvim-treesitter.ts_utils
             nvim aniseed.nvim
             core aniseed.core}})

(defn get-cursor-pos
  []
  (nvim.win_get_cursor 0))

(defn set-cursor-pos
  [pos]
  (nvim.win_set_cursor 0 pos))

(defn pos+ [[a b] [c d]]
  [(+ a c) (+ b d)])

(defn pos- [[a b] [c d]]
  [(- a c) (- b d)])

(defn nstart [node]
  (let [[r c] [(node:start)]]
    [(+ r 1) c]))

(defn nend [node]
  (let [[r c] [(node:end_)]]
    [(+ r 1) c]))

(defn pos< [[a b] [c d]]
  (or (< a c)
      (and (= a c) (< b d))))

(defn cursor-offset-from-start
  [node]
  (let [start-pos (nstart node)
        current-pos (get-cursor-pos)]
    (pos- current-pos start-pos)))

(defn cursor-to-prev-sibling
  [node ?end ?no-jump]
  (ts.goto_node (node:prev_sibling) ?end ?no-jump)
  node)

