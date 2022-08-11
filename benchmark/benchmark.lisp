(asdf:load-system "ironclad")

(defparameter *lisp-implementations*
  `(("ABCL" "abcl --load benchmark-implementation.lisp")
    ("AllegroCL" ,(format nil
                          "alisp -L ~a -e '(let ((*default-pathname-defaults* ~s)) (load \"benchmark-implementation.lisp\"))'"
                          (merge-pathnames ".clinit.cl" (user-homedir-pathname))
                          (uiop:getcwd)))
    ("ClozureCL" "ccl --load benchmark-implementation.lisp")
    ("Clisp" "clisp -i benchmark-implementation.lisp")
    ("ECL" "ecl --load benchmark-implementation.lisp")
    ("SBCL" "sbcl --load benchmark-implementation.lisp")))
(defparameter *implementation-result-file* "benchmark-tmp")
(defparameter *result-file* "benchmark.org")

;;; results format:
;;;
;;; (("lisp1" (("version" "...")
;;;            ("ciphers" (("cipher1" speed1)
;;;                        ("cipher2" speed2)
;;;                        (...)))
;;;            ("digests" (("digest1" speed1)
;;;                        ("digest2" speed2)
;;;                        (...)))
;;;            ("macs" (("mac1" speed1)
;;;                     ("mac2" speed2)
;;;                     (...)))
;;;            ("modes" (("mode1" speed1)
;;;                      ("mode2" speed2)
;;;                      (...)))
;;;            ("diffie-hellman" (("diffie-hellman1" speed1)
;;;                               ("diffie-hellman2" speed2)
;;;                               (...)))
;;;            ("message-encryptions" (("encryption1" speed1)
;;;                                    ("encryption2" speed2)
;;;                                    (...)))
;;;            ("signatures" (("signature1" speed1)
;;;                           ("signature2" speed2)
;;;                           (...)))
;;;            ("verifications" (("verification1" speed1)
;;;                              ("verification2" speed2)
;;;                              (...)))))
;;;  ("lisp2" ...)
;;;  (...))
(defun write-result-file (results)
  (with-open-file (file *result-file* :direction :output :if-exists :supersede)
    (format file "#+TITLE: Speed benchmark of the Ironclad crypto library~%~%")
    (format file "Ironclad version: ~a~%~%" (asdf:component-version (asdf:find-system "ironclad")))
    (format file "Processor: ~a (~a)~%" (machine-type) (machine-version))
    (format file "Operating system: ~a (~a)~%~%" (software-type) (software-version))
    (format file "Common Lisp implementations:~%")
    (dolist (implementation *lisp-implementations*)
      (let ((lisp (car implementation)))
        (format file " - ~a: ~a~%" lisp (cdr (assoc "version"
                                                    (cdr (assoc lisp results :test #'string=))
                                                    :test #'string=)))))
    (terpri file)

    (let ((line "|----------------"))
      (dotimes (i (length *lisp-implementations*))
        (setf line (concatenate 'string line "+------------")))
      (setf line (concatenate 'string line "|"))

      (format file "* Ciphers~%~%")
      (format file "Encryption speed in bytes per second~%~%")
      (format file "~a~%" line)
      (format file "|                |")
      (dolist (implementation *lisp-implementations*)
        (let ((lisp (car implementation)))
          (format file " ~10a |" lisp)))
      (terpri file)
      (format file "~a~%" line)
      (dolist (cipher-name (ironclad:list-all-ciphers))
        (format file "| ~14a |" cipher-name)
        (dolist (implementation *lisp-implementations*)
          (let* ((lisp (car implementation))
                 (result (cdr (assoc "ciphers"
                                     (cdr (assoc lisp results :test #'string=))
                                     :test #'string=)))
                 (speed (cdr (assoc cipher-name result :test #'string=))))
            (format file " ~10@a |" speed)))
        (terpri file))
      (format file "~a~%~%" line)

      (format file "* Digests~%~%")
      (format file "Hashing speed in bytes per second~%~%")
      (format file "~a~%" line)
      (format file "|                |")
      (dolist (implementation *lisp-implementations*)
        (let ((lisp (car implementation)))
          (format file " ~10a |" lisp)))
      (terpri file)
      (format file "~a~%" line)
      (dolist (digest-name (ironclad:list-all-digests))
        (format file "| ~14a |" digest-name)
        (dolist (implementation *lisp-implementations*)
          (let* ((lisp (car implementation))
                 (result (cdr (assoc "digests"
                                     (cdr (assoc lisp results :test #'string=))
                                     :test #'string=)))
                 (speed (cdr (assoc digest-name result :test #'string=))))
            (format file " ~10@a |" speed)))
        (terpri file))
      (format file "~a~%~%" line)

      (format file "* Message authentication codes~%~%")
      (format file "CMAC: AES~%")
      (format file "GMAC: AES~%")
      (format file "HMAC: SHA256~%")
      (format file "SKEIN-MAC: SKEIN512~%~%")
      (format file "Hashing speed in bytes per second~%~%")
      (format file "~a~%" line)
      (format file "|                |")
      (dolist (implementation *lisp-implementations*)
        (let ((lisp (car implementation)))
          (format file " ~10a |" lisp)))
      (terpri file)
      (format file "~a~%" line)
      (dolist (mac-name (ironclad:list-all-macs))
        (format file "| ~14a |" mac-name)
        (dolist (implementation *lisp-implementations*)
          (let* ((lisp (car implementation))
                 (result (cdr (assoc "macs"
                                     (cdr (assoc lisp results :test #'string=))
                                     :test #'string=)))
                 (speed (cdr (assoc mac-name result :test #'string=))))
            (format file " ~10@a |" speed)))
        (terpri file))
      (format file "~a~%~%" line)

      (format file "* Block cipher modes~%~%")
      (format file "Cipher: AES~%~%")
      (format file "Encryption speed in bytes per second~%~%")
      (format file "~a~%" line)
      (format file "|                |")
      (dolist (implementation *lisp-implementations*)
        (let ((lisp (car implementation)))
          (format file " ~10a |" lisp)))
      (terpri file)
      (format file "~a~%" line)
      (dolist (mode-name (ironclad:list-all-modes))
        (format file "| ~14a |" mode-name)
        (dolist (implementation *lisp-implementations*)
          (let* ((lisp (car implementation))
                 (result (cdr (assoc "modes"
                                     (cdr (assoc lisp results :test #'string=))
                                     :test #'string=)))
                 (speed (cdr (assoc mode-name result :test #'string=))))
            (format file " ~10@a |" speed)))
        (terpri file))
      (format file "~a~%~%" line)

      (format file "* Diffie-Hellman key exchanges~%~%")
      (format file "ELGAMAL: 2048 bits~%~%")
      (format file "Diffie-Hellman speed in exchanges per second~%~%")
      (format file "~a~%" line)
      (format file "|                |")
      (dolist (implementation *lisp-implementations*)
        (let ((lisp (car implementation)))
          (format file " ~10a |" lisp)))
      (terpri file)
      (format file "~a~%" line)
      (dolist (dh-name '(:curve25519 :curve448 :elgamal
                         :secp256k1 :secp256r1 :secp384r1 :secp521r1))
        (format file "| ~14a |" dh-name)
        (dolist (implementation *lisp-implementations*)
          (let* ((lisp (car implementation))
                 (result (cdr (assoc "diffie-hellman"
                                     (cdr (assoc lisp results :test #'string=))
                                     :test #'string=)))
                 (speed (cdr (assoc dh-name result :test #'string=))))
            (format file " ~10@a |" speed)))
        (terpri file))
      (format file "~a~%~%" line)

      (format file "* Message encryptions~%~%")
      (format file "ELGAMAL: 2048 bits~%")
      (format file "RSA: 2048 bits~%~%")
      (format file "Message encryption speed in encryptions per second~%~%")
      (format file "~a~%" line)
      (format file "|                |")
      (dolist (implementation *lisp-implementations*)
        (let ((lisp (car implementation)))
          (format file " ~10a |" lisp)))
      (terpri file)
      (format file "~a~%" line)
      (dolist (encryption-name '(:elgamal :rsa))
        (format file "| ~14a |" encryption-name)
        (dolist (implementation *lisp-implementations*)
          (let* ((lisp (car implementation))
                 (result (cdr (assoc "message-encryptions"
                                     (cdr (assoc lisp results :test #'string=))
                                     :test #'string=)))
                 (speed (cdr (assoc encryption-name result :test #'string=))))
            (format file " ~10@a |" speed)))
        (terpri file))
      (format file "~a~%~%" line)

      (format file "* Signatures~%~%")
      (format file "DSA: 2048 bits~%")
      (format file "ELGAMAL: 2048 bits~%")
      (format file "RSA: 2048 bits~%~%")
      (format file "Signature speed in signatures per second~%~%")
      (format file "~a~%" line)
      (format file "|                |")
      (dolist (implementation *lisp-implementations*)
        (let ((lisp (car implementation)))
          (format file " ~10a |" lisp)))
      (terpri file)
      (format file "~a~%" line)
      (dolist (signature-name '(:dsa :ed25519 :ed448 :elgamal :rsa
                                :secp256k1 :secp256r1 :secp384r1 :secp521r1))
        (format file "| ~14a |" signature-name)
        (dolist (implementation *lisp-implementations*)
          (let* ((lisp (car implementation))
                 (result (cdr (assoc "signatures"
                                     (cdr (assoc lisp results :test #'string=))
                                     :test #'string=)))
                 (speed (cdr (assoc signature-name result :test #'string=))))
            (format file " ~10@a |" speed)))
        (terpri file))
      (format file "~a~%~%" line)

      (format file "* Signature verifications~%~%")
      (format file "DSA: 2048 bits~%")
      (format file "ELGAMAL: 2048 bits~%")
      (format file "RSA: 2048 bits~%~%")
      (format file "Signature verification speed in verifications per second~%~%")
      (format file "~a~%" line)
      (format file "|                |")
      (dolist (implementation *lisp-implementations*)
        (let ((lisp (car implementation)))
          (format file " ~10a |" lisp)))
      (terpri file)
      (format file "~a~%" line)
      (dolist (signature-name '(:dsa :ed25519 :ed448 :elgamal :rsa
                                :secp256k1 :secp256r1 :secp384r1 :secp521r1))
        (format file "| ~14a |" signature-name)
        (dolist (implementation *lisp-implementations*)
          (let* ((lisp (car implementation))
                 (result (cdr (assoc "verifications"
                                     (cdr (assoc lisp results :test #'string=))
                                     :test #'string=)))
                 (speed (cdr (assoc signature-name result :test #'string=))))
            (format file " ~10@a |" speed)))
        (terpri file))
      (format file "~a~%~%" line))))

(defun benchmark ()
  (let ((results '()))
    (dolist (implementation *lisp-implementations*)
      (let ((lisp (car implementation))
            (command (cadr implementation)))
        (format t "Benchmarking ~a..." lisp)
        (finish-output)
        (let ((result (ignore-errors
                        (uiop:run-program command)
                        (with-open-file (file *implementation-result-file*)
                          (setf results (acons lisp (read file) results))))))
          (if (null result)
              (format t " FAILED~%")
              (format t " OK~%")))
        (uiop:delete-file-if-exists *implementation-result-file*)))
    (write-result-file results)
    (format t "Benchmark result written to \"~a\"~%" *result-file*)))

(benchmark)
