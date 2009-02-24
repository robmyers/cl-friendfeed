(asdf:operate 'asdf:load-op 'drakma)   ;; HTTP client
(asdf:operate 'asdf:load-op 'cl-json)  ;; JSON parser
(asdf:operate 'asdf:load-op 'cl-base64)

(defpackage #:cl-friendfeed
  (:use :cl #:drakma #:json #:cl-base64)
  (:export

   #:friendfeed-auth
   
   #:fetch-user-feed
   #:fetch-user-likes-feed
   
))