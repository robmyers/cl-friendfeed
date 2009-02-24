(in-package :cl-friendfeed)

(defun url-encode (str)
  (drakma::alist-to-url-encoded-string str *drakma-default-external-format*))

(defparameter $friendfeed-api-url "http://friendfeed.com")

;;TODO: Write access to server
;;TODO: Date parsing
;;TODO: Comments, especially noting authorization

(defclass friendfeed-auth ()
  ((nickname :accessor auth-nickname :initarg :nickname)
   (key :accessor auth-key :initarg :key)))

(defmethod friendfeed-auth-headers ((auth friendfeed-auth))
  (list  (cons "Authorization"
               (format nil "Basic ~a"
                       (string-to-base64-string (format nil "~a:~a"
							(auth-nickname auth)
							(auth-key auth)))))))

(defmethod friendfeed-uri-with-args (uri url-args)
  (concatenate 'string
               $friendfeed-api-url
               uri
               "?"
               (url-encode url-args)))

(defmethod fetch (auth uri post-args url-args)
  (let ((args (list (friendfeed-uri-with-args uri 
					      (cons '("format" . "json")
						    url-args ))
		    :method :get)))
    (when (and auth (auth-nickname auth) (auth-key auth))
      (setf args (concatenate 'list 
			      (list :additional-headers 
				    (friendfeed-auth-headers auth))
			      args)))
    (multiple-value-bind (body result-code) (apply #'http-request args)
      ;; Hacky check for JSON
      (if (string= (subseq body 0 1) "{")
	  (decode-json-from-string body) 
	  nil))))

(defmethod fetch-feed (auth uri key-args &optional post-args)
  ;; Do any swizzling of return parameters here
  (fetch auth uri post-args key-args))


(defmethod fetch-public-feed (args)
  (fetch-feed nil
              "/api/feed/public"
              args))

(defmethod fetch-user-feed ((feed friendfeed-auth) (nickname string) args)
  (fetch-feed feed
              (concatenate 'string 
			   "/api/feed/user" 
			   (url-encode nickname))
              args))

(defmethod fetch-user-comments-feed ((feed friendfeed-auth) (nickname string) 
				     args)
  (fetch-feed feed
              (concatenate 'string "/api/feed/user"
                           (url-encode nickname) "/comments")
              args))

(defmethod fetch-user-likes-feed ((feed friendfeed-auth) (nickname string) args)
  (fetch-feed feed
              (concatenate 'string "/api/feed/user"
                           (url-encode nickname) "/likes")
              args))

(defmethod fetch-user-discussion-feed ((feed friendfeed-auth) (nickname string)
                                       args)
  (fetch-feed feed
              (concatenate 'string "/api/feed/user"
                           (url-encode nickname) "/discussion")
              args))

;;FIXME
(defmethod fetch-multi-user-feed ((feed friendfeed-auth) (nickname string) args)
  (fetch-feed feed
              (concatenate 'string "/api/feed/user"
                           (url-encode nickname) "/likes")
              args))


(defmethod fetch-home-feed ((feed friendfeed-auth) args)
  (fetch-feed feed "/api/feed/home" args))

(defmethod fetch-search ((feed friendfeed-auth) q args)
  (fetch-feed "/api/feed/search" (cons (cons "q" q) args)))