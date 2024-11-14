(config
  (theme "tokyostorm")
  (editor
    (auto-save true)
    (mouse false)
    (cursorline true)
    (true-color true)
    (sticky-context.enable true))
    (gutters '["one" "two"])
  (editor.soft-wrap
    (enable true)))

(define (set-config-rec conf "") ())
(define-syntax config (syntax-rules () [(config conf) (set-config-rec (quote conf) "")]))

(set "theme" "tokyostorm")
(set "editor.auto-save" true)
(set "editor.mouse" false)
(set "editor.soft-wrap.enable" true)
