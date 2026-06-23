;;; face-test.el --- Assert stryke-mode font-lock faces -*- lexical-binding: t; -*-

;; Loads stryke-mode, fontifies a sample, and asserts the face applied at the
;; first occurrence of each probe token. Run:
;;   emacs --batch -L . -l scripts/face-test.el

;;; Code:

(require 'stryke-mode)

(defvar stryke-face-test--sample
  (concat
   "#!/usr/bin/env stryke\n"
   "use strict;\n"
   "my $name = \"hello $who\";\n"
   "fn greet ($w: Str) {\n"
   "    say \"yo\";\n"
   "    my @r = pmap { $_ } 1..10;\n"
   "    my $a = absorbance(0.5);\n"
   "    return contains(@r, 3);\n"
   "}\n"
   "async fn go { await spawn { 1 } }\n"
   "# a trailing comment\n"))

(defun stryke-face-test--face-of (token)
  "Return the face text-property at the start of the first whole-symbol TOKEN.
Case-sensitive and symbol-bounded so e.g. \"Str\" does not match \"stryke\"."
  (goto-char (point-min))
  (let ((case-fold-search nil))
    (if (re-search-forward (concat "\\_<" (regexp-quote token) "\\_>") nil t)
        (let ((face (get-text-property (match-beginning 0) 'face)))
          (if (listp face) (car face) face))
      'NOT-FOUND)))

(let ((checks
       '(("use"        . font-lock-keyword-face)
         ("my"         . font-lock-keyword-face)
         ("fn"         . font-lock-keyword-face)
         ("Str"        . font-lock-type-face)
         ("say"        . font-lock-builtin-face)
         ("pmap"       . stryke-parallel-face)
         ("absorbance" . font-lock-builtin-face)
         ("contains"   . font-lock-builtin-face)
         ("async"      . font-lock-keyword-face)
         ("await"      . font-lock-keyword-face)
         ("BEGIN"      . nil)))                ; not in sample; sanity only
      (failed 0))
  (with-temp-buffer
    (insert stryke-face-test--sample)
    (stryke-mode)
    (font-lock-ensure)
    ;; quoted string + comment via syntax table
    (let* ((str-face (stryke-face-test--face-of "hello"))
           (com-face (stryke-face-test--face-of "trailing")))
      (dolist (probe (butlast checks))   ; drop the BEGIN sanity row
        (let* ((token (car probe))
               (want (cdr probe))
               (got (stryke-face-test--face-of token))
               (ok (eq got want)))
          (unless ok (setq failed (1+ failed)))
          (princ (format "%s  %-12s want=%-26s got=%s\n"
                         (if ok "PASS" "FAIL") token want got))))
      (let ((ok (eq str-face 'font-lock-string-face)))
        (unless ok (setq failed (1+ failed)))
        (princ (format "%s  %-12s want=%-26s got=%s\n"
                       (if ok "PASS" "FAIL") "<string>" 'font-lock-string-face str-face)))
      (let ((ok (eq com-face 'font-lock-comment-face)))
        (unless ok (setq failed (1+ failed)))
        (princ (format "%s  %-12s want=%-26s got=%s\n"
                       (if ok "PASS" "FAIL") "<comment>" 'font-lock-comment-face com-face)))))
  (princ (if (zerop failed) "\nALL FACE CHECKS PASSED\n" (format "\n%d CHECK(S) FAILED\n" failed)))
  (kill-emacs (if (zerop failed) 0 1)))

;;; face-test.el ends here
