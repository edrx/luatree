;; This file:
;;   http://angg.twu.net/luatree/luatree.lisp.html
;;   http://angg.twu.net/luatree/luatree.lisp
;;           (find-angg "luatree/luatree.lisp")
;; Author: Eduardo Ochs <eduardoochs@gmail.com>
;;
;; (defun lu () (interactive) (find-angg "luatree/luatree.lua"))
;; (defun l  () (interactive) (find-angg "luatree/luatree.lisp"))
;; (defun m  () (interactive) (find-angg "luatree/luatree.mac"))
;; (find-es "maxima" "luatree")

(require :asdf)

(defun luatree-lua (bigstr)
  (with-input-from-string
   (s bigstr)
   (reduce (lambda (a b) (format nil "~a~%~a" a b))
	   (uiop:run-program "~/luatree/luatree.lua" :input s :output :lines))))

(defmfun $luatree_lua (str) (luatree-lua str))

#|
 (eepitch-maxima)
 (eepitch-kill)
 (eepitch-maxima)
to_lisp();
  (load "luatree.lisp")
  (defvar aaa)
  (setf aaa "{[0]=\"[\", {[0]=\"/\", \"x\", \"y\"}, \"33\"}")
  (luatree-lua aaa)

|#
