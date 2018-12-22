(ns film-ratings.handler.index
  (:require [ataraxy.core :as ataraxy]
            [ataraxy.response :as response]
            [film-ratings.views.index :as views.index]
            [integrant.core :as ig]))

(defmethod ig/init-key :film-ratings.handler/index [_ _]
  (fn [{[_] :ataraxy/result}]
    [::response/ok (views.index/list-options)]))
