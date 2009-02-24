;;; -*- lisp -*-

;; ASDF system definition for loading the .


(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :cl-friendfeed.system)
    (defpackage :cl-friendfeed.system
      (:use :common-lisp :asdf))))

(in-package :cl-friendfeed.system)

(defsystem :cl-friendfeed
  :version "0.1"
  :depends-on (:drakma :cl-json :cl-base64)
  :author "Rob Myers"
  :components ((:static-file "cl-friendfeed.asd")
	       (:module :src
			:components ((:file "packages")
				     	 (:file "cl-friendfeed"
					     :depends-on ("packages"))))))