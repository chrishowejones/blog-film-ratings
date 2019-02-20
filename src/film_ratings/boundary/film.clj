(ns film-ratings.boundary.film
  (:require [clojure.java.jdbc :as jdbc]
            duct.database.sql)
  (:import java.sql.SQLException))

(defprotocol FilmDatabase
  (list-films [db])
  (fetch-films-by-name [db name])
  (create-film [db film]))

(extend-protocol FilmDatabase
  duct.database.sql.Boundary
  (list-films [{db :spec}]
    (jdbc/query db ["SELECT * FROM film"]))
  (fetch-films-by-name [{db :spec} name]
    (let [search-term (str "%" name "%")]
      (jdbc/query db ["SELECT * FROM film WHERE LOWER(name) like LOWER(?)" search-term])))
  (create-film [{db :spec} film]
    (try
     (let [result (jdbc/insert! db :film film)]
       (if-let [id (val (ffirst result))]
         {:id id}
         {:errors ["Failed to add film."]}))
     (catch SQLException ex
       {:errors [(format "Film not added due to %s" (.getMessage ex))]}))))
