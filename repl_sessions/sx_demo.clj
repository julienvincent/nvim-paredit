(ns sx-demo)

(def foo 1)

(defn my-func []
  {:name "Artem"
   :login :armed})

(let [foo 1]
  "asdfasd"
  (str 2) str foo
  3 5
  (* 10 2))

(comment
  [1 2 3 4
   #{1 2 3}
   {:s 1
    :b 2}])

(let [f {:foo 1}]   )
  z 2

(defn handle-initial-manifest-fetch-error
  "If the `--fallback` option is set and the error was a network
  timeout use the previous manifest instead of failing otherwise
  fail."
  [[state _ :as ctx] ex]
  (let [{:keys [cache-fallback retry-fetch]} state
        network-error? (or (= (error/unknown-host ex) 
                              (:manifest-url state))
                           (error/network-timeout? ex))
        parsing-error? (manifest.parser/parsing-error? ex)]
    (log/info :manifest-fetch/failed
              (into {}
                    (filter val)
                    {:cache-fallback cache-fallback
                     :retry-fetch retry-fetch
                     :network-error? network-error?
                     :parsing-error? parsing-error?}))
    (cond
      parsing-error? (log/info "Failed to parse initial manifest!")

      network-error? (log/info "Initial fetch failed due to network error!"))

    (cond  
      cache-fallback
      (do (log/info "Cache fallback set. Falling back to cached manifest.")
          (start-initial-process ctx))

      retry-fetch 
      (do (log/info "Retry fetch set. Retrying fetch according to schedule.")
          (schedule-next-manifest-query ctx events/LOOK-FOR-INITIAL-MANIFEST))
      
      :else (do (log/info :initial-fetch-failed/giving-up)
                (cleanup state)
                (throw ex)))))
