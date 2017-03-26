(use extras medea)

;;
;; apex generic functions
;; should get moved into an extension
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; apex uses stdout for response data,  so all logs should go to stderr
(define (log-line s)
  (format (current-error-port) "~A\n" s))

;; as-apex-result is called on a successful invocation
(define (as-apex-result v)
  `((value . ,v)))

;; as-apex-error should be called when an error occurs
(define (as-apex-error v)
  `((error . ,v)))

;; apex-invoke accepts a procedure and a single request line
;; that is a string of JSON representing a single AWS Lambda invocation
;;
;; fn is invoked and the result is written to stdout as JSON
;;
(define (apex-invoke fn input)
  (begin
    (define output (json->string (as-apex-result (fn input))))
    (log-line (format #f "input: ~A\noutput: ~A" input output))
    (write-line output)
    (flush-output)))

;; apex-loop is the main run loop
;; it reads stdin line by line, executing apex-handle-req once per line
;; the loop terminates when stdin is exhausted
(define (apex-loop fn)
  (let ((line (read-line)))
    (if (eof-object? line)
        line
        (begin
          (apex-invoke fn line)
          (apex-loop fn)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; our actual function
;;
(define (sum-func input)
  (let* ((json (read-json input))
         (nums (alist-ref 'numbers (alist-ref 'event json))))
     (apply + (vector->list nums))))

;;
;; main - note that apex uses stdout for response data,
;;        so all logs should go to stderr
;;
(log-line "chicken sum starting")
(apex-loop sum-func)
(log-line "chicken sum exiting")
