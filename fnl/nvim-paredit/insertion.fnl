(module nvim-paredit.insertion
  {autoload {util nvim-paredit.util
             p nvim-paredit.position}})

(defn insert-at-cursor [s j]
  (let [pos (p.get-cursor-pos)
        l (vim.api.nvim_get_current_line)]
    (vim.api.nvim_set_current_line
      (.. (string.sub l 1 (. pos 2))
          s
          (string.sub l (+ (. pos 2) 1))))
    (p.set-cursor-pos (p.pos+ pos [0 j]))))

(defn next-char
  []
  (let [pos (p.get-cursor-pos)
        l (vim.api.nvim_get_current_line)]
    (when (> (length l) (+ (. pos 2) 1))
      (string.sub l (+ (. pos 2) 1) (+ (. pos 2) 1)))))
