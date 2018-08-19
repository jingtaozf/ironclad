;;;; -*- mode: lisp; indent-tabs-mode: nil -*-
;;;; aead.lisp -- authenticated encryption with associated data

(in-package :crypto)


(defclass aead-mode ()
  ((encryption-started :accessor encryption-started-p
                       :initform nil
                       :type boolean)
   (associated-data-length :accessor associated-data-length
                           :initform 0
                           :type (integer 0 *))
   (encrypted-data-length :accessor encrypted-data-length
                          :initform 0
                          :type (integer 0 *))
   (tag :accessor tag)))

(defmethod shared-initialize :after ((mode aead-mode) slot-names &rest initargs &key tag &allow-other-keys)
  (declare (ignore slot-names initargs))
  (setf (encryption-started-p mode) nil
        (associated-data-length mode) 0
        (encrypted-data-length mode) 0
        (tag mode) (copy-seq tag))
  mode)

(defun aeadp (name)
  (get name 'aead))

(defun list-all-authenticated-encryption-modes ()
  (loop for symbol being each external-symbol of (find-package :ironclad)
        if (aeadp symbol)
          collect symbol into ciphers
        finally (return (sort ciphers #'string<))))

(defun authenticated-encryption-mode-supported-p (name)
  (and (symbolp name) (aeadp name)))

(defmacro defaead (name)
  `(setf (get ',name 'aead) t))

(defun make-authenticated-encryption-mode (name &rest args)
  (typecase name
    (symbol
     (let ((name (massage-symbol name)))
       (if (aeadp name)
           (apply #'make-instance name args)
           (error 'unsupported-authenticated-encryption-mode :name name))))
    (t
     (error 'type-error :datum name :expected-type 'symbol))))