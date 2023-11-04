(require-builtin steel/random as rand::)
(require-builtin helix/core/static as helix.static.)
(require-builtin helix/core/typable as helix.)

(require "cogs/keymaps.scm")
(require (only-in "cogs/options.scm" apply-options))

(require (only-in "cogs/file-tree.scm" FILE-TREE-KEYBINDINGS FILE-TREE))

(require (only-in "cogs/recentf.scm" recentf-open-files get-recent-files))

;;;;;;;;;;;;;;;;;;;;;;;; Default modes ;;;;;;;;;;;;;;;;;;;;;;;

;; Enable the recentf snapshot, will watch every 2 minutes for active files,
;; and flush those down to disk
(recentf-snapshot *helix.cx*)

;  (define scheme-configuration
;    (hash "language"
;          (list (hash "auto-format"
;                      #t
;                      "name"
;                      "scheme"
;                      "grammar"
;                      "scheme"
;                      "formatter"
;                      (hash "args" '("fmt" "-i") "command" "raco")
;                      "file-types" '("scm")))))

;  (let ([result (hx.languages.register-language-configuration!
;                 (value->jsexpr-string scheme-configuration))])

;    (when (Err? result)
;      (error result)))

;  (hx.languages.flush-configuration *helix.cx*)

;;;;;;;;;;;;;;;;;;;;;;;;;; Keybindings ;;;;;;;;;;;;;;;;;;;;;;;

;; To remove a binding, set it to 'no_op
;; For example, this will make it impossible to enter insert mode:
;; (hash "normal" (hash "i" 'no_op))

;; Set the global keybinding for now
(add-global-keybinding
 (hash
  "normal"
  (hash
   "C-r"
   (hash "f" ":recentf-open-files")
   )))

(define scm-keybindings (hash "insert" (hash "ret" ':scheme-indent "C-l" ':insert-lambda)))

;; Grab whatever the existing keybinding map is
(define standard-keybindings (deep-copy-global-keybindings))

(define file-tree-base (deep-copy-global-keybindings))

(merge-keybindings standard-keybindings scm-keybindings)
(merge-keybindings file-tree-base FILE-TREE-KEYBINDINGS)

;; <scratch> + <doc id> is probably the best way to handle this?
(set-global-buffer-or-extension-keymap (hash "scm" standard-keybindings FILE-TREE file-tree-base))

;;;;;;;;;;;;;;;;;;;;;;;;;; Options ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define *config-map* '((auto-save true) (mouse false) (cursorline true) (soft-wrap.enable true)))

(apply-options *helix.cx* *config-map*)
;; Probably should be a symbol?

; (register-hook! 'post-insert-char 'prompt-on-char-press)
