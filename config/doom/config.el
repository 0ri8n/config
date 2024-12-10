;; [[file:config.org::*user][user:1]]
(setq user-full-name "emil lenz"
      user-mail-address "emillenz@protonmail.com")
;; user:1 ends here

;; [[file:config.org::*global options][global options:1]]
(let ((width 100))
  (setq fill-column width
        async-shell-command-width width
        visual-fill-column-width width))

(global-visual-fill-column-mode)
(global-visual-line-mode)
;; global options:1 ends here

;; [[file:config.org::*global options][global options:2]]
(setq initial-scratch-message ""
      delete-by-moving-to-trash t
      bookmark-default-file "~/.config/doom/bookmarks" ;; save bookmarks in config dir (to preserve inbetween newinstalls)
      auto-save-default t
      confirm-kill-emacs nil
      enable-recursive-minibuffers t) ;; all of emacs available even if in minibuffer.

(save-place-mode)

(global-subword-mode)

(add-hook! prog-mode-hook #'rainbow-delimiters-mode)

(setq global-auto-revert-non-file-buffers t)
(global-auto-revert-mode)
;; global options:2 ends here

;; [[file:config.org::*global options][global options:3]]
(add-hook! 'prog-mode-hook
  (visual-fill-column-mode -1))
;; global options:3 ends here

;; [[file:config.org::*global options][global options:4]]
(advice-add '+default/man-or-woman :override #'man)
;; global options:4 ends here

;; [[file:config.org::*modus-theme][modus-theme:1]]
(use-package! modus-themes
  :config
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-common-palette-overrides `((fg-region unspecified) ;; don't grey out syntax highlighting in active region
                                                (fg-heading-1 fg-heading-0))) ;; colorize (before: black)
  ;; list of customizeable faces: `(helpful-variable 'modus-themes-faces)`
  (custom-set-faces!
    '(org-list-dt :inherit modus-themes-heading-1)
    `(org-block-begin-line :foreground ,(modus-themes-get-color-value 'prose-metadata))
    '(org-quote :slant italic)

    '(comint-highlight-prompt :weight bold))

  (setq doom-theme 'modus-operandi))
;; modus-theme:1 ends here

;; [[file:config.org::*modus-theme][modus-theme:2]]
(add-hook! 'org-mode-hook
  (face-remap-add-relative 'whitespace-tab 'org-block))
;; modus-theme:2 ends here

;; [[file:config.org::*font][font:1]]
(setq doom-font (font-spec :family "Iosevka Comfy" :size 13))
(setq doom-variable-pitch-font (font-spec :family "Noto Serif" :size 13))

(set-face-attribute 'line-number nil :inherit 'fixed)

(after! shr
  (setq shr-use-fonts nil))
;; font:1 ends here

;; [[file:config.org::*modeline][modeline:1]]
(setq display-battery-mode nil
      display-time-mode nil
      +modeline-height 8
      +modeline-bar-width nil) ;; hide unicode sugar
;; modeline:1 ends here

;; [[file:config.org::*display buffers][display buffers:1]]
(setq display-buffer-alist `((,(rx (seq "*" (or "transient"
						(seq "Org " (or "Select" "todo"))
						"Agenda Commands"
						"doom eval"
						"Backtrace"
						"lsp-help"
						"Async Shell Command")))
			      display-buffer-in-side-window
			      (window-height . fit-window-to-buffer)
			      (side . bottom))

			     ("."
			      display-buffer-same-window))

      switch-to-buffer-obey-display-actions t)
;; display buffers:1 ends here

;; [[file:config.org::*display buffers][display buffers:2]]
(after! org
  (setq org-src-window-setup 'plain ;; use display-buffer setting
        org-agenda-window-setup 'current-window))

(after! man
  (setq Man-notify-method 'pushy))

(advice-add #'switch-to-buffer-other-window :override #'switch-to-buffer)

(after! cider
  (setq ;; cider-auto-select-error-buffer
	;; cider-inspector-auto-select-buffer
	cider-jump-to-pop-to-buffer-actions '((display-buffer-in-side-window))))

(after! magit
  (setq magit-commit-diff-inhibit-same-window t
        +magit-open-windows-in-direction 'down))
;; display buffers:2 ends here

;; [[file:config.org::*line numbers][line numbers:1]]
(setq display-line-numbers-type 'relative)
;; line numbers:1 ends here

;; [[file:config.org::*rationale][rationale:1]]
(defvar u/global-indent-width 8)

(setq-default indent-tabs-mode t
              tab-width u/global-indent-width
              standard-indent u/global-indent-width
              evil-indent-convert-tabs t
              evil-shift-width u/global-indent-width
              org-indent-indentation-per-level u/global-indent-width)

(setq c-default-style "linux")

(after! sh-script
  sh-basic-offset u/global-indent-width)
;; rationale:1 ends here

;; [[file:config.org::*evil-mode][evil-mode:1]]
(after! evil
;; evil-mode:1 ends here

;; [[file:config.org::*evil-mode][evil-mode:2]]
(evil-surround-mode)
(setq evil-want-fine-undo nil
      evil-magic 'very-nomagic
      evil-ex-substitute-global t
      evil-want-C-i-jump t
      evil-want-C-h-delete t
      evil-want-minibuffer t ;; don't loose our powers in the minibuffer
      evil-org-use-additional-insert nil)

(defadvice! u/preserve-point (fn &rest args)
  :around '(anzu-query-replace-regexp
            query-replace-regexp
            +format:region)
  (save-excursion
    (apply fn args)))

;; FIXME :: `+fold/previous` disabled, since it crashes emacs. (don't call it by accident via binding)
(advice-add '+fold/previous :override #'ignore)

;; HACK :: sometimes cursor stays int normal-mode (even though we are in insert mode).  this fixes the inconsistency.
(setq-hook! 'minibuffer-setup-hook cursor-type 'bar)
;; evil-mode:2 ends here

;; [[file:config.org::*evil-mode][evil-mode:3]]
(dolist (cmd '(flycheck-next-error
		 flycheck-previous-error
		 +lookup/definition
		 +lookup/references
		 +lookup/implementations
		 +default/search-buffer
		 consult-imenu))
  (evil-add-command-properties cmd :jump t))

(dolist (cmd '(evil-backward-section-begin
		 evil-forward-section-begin
		 evil-jump-item
		 evil-backward-paragraph
		 evil-forward-paragraph
		 evil-forward-section-end))
  (evil-remove-command-properties cmd :jump))
;; evil-mode:3 ends here

;; [[file:config.org::*evil-mode][evil-mode:4]]
(defadvice! u/update-last-macro-register (fn &rest args)
  "when a macro was recorded and `evil-last-register' is still `nil' (no macro was executed yet),
  set it to the just recorded macro.

this is the sane default behaviour for 99% of the time: record a quick macro with 'qq' and
immediately call it with '@@', instead of getting an error, getting annoyed and having to retype
'@q' (the exact key) for the first time and then only after that we may call '@@'."
  :after #'evil-record-macro
  (when (not evil-last-register)
    (setq-local evil-last-register evil-last-recorded-register)))
;; evil-mode:4 ends here

;; [[file:config.org::*evil-mode][evil-mode:5]]
(after! savehist
  (add-to-list 'savehist-additional-variables 'evil-markers-alist)

  (add-hook! 'savehist-save-hook
    (kill-local-variable 'evil-markers-alist)
    (dolist (entry evil-markers-alist)
      (when (->> (cdr entry)
		 markerp)
	(setcdr entry
		(cons (->> entry
			   cdr
			   marker-buffer
			   buffer-file-name
			   file-truename)
		      (->> entry
			   cdr
			   marker-position))))))

  (add-hook! 'savehist-mode-hook
    (setq-default evil-markers-alist evil-markers-alist)
    (kill-local-variable 'evil-markers-alist)
    (make-local-variable 'evil-markers-alist)))
;; evil-mode:5 ends here

;; [[file:config.org::*evil-mode][evil-mode:6]]
)
;; evil-mode:6 ends here

;; [[file:config.org::*leaderkey][leaderkey:1]]
(setq doom-leader-key "SPC"
      doom-leader-alt-key "C-SPC"
      doom-localleader-key "SPC m")

(map! :leader
      "'" #'consult-bookmark

      (:prefix "h"
               "w" #'tldr)
      (:prefix "s"
               "k" #'devdocs-lookup
               "t" #'dictionary-search)
      (:prefix "f"
               "f" #'+vertico/consult-fd-or-find)
      (:prefix "t"
	       "a" #'toggle-text-mode-auto-fill)
      (:prefix "c"
               "r" #'lsp-rename
               (:prefix "'"
                        "t" #'org-babel-tangle
                        "T" #'org-babel-detangle))
      (:prefix "n"
               "g" #'org-capture-goto-last-stored))
;; leaderkey:1 ends here

;; [[file:config.org::*completion & minibuffer][completion & minibuffer:1]]
(map! :map minibuffer-mode-map
      :n "j"   #'next-history-element
      :n "k"   #'previous-history-element
      :n "/"   #'previous-matching-history-element
      :n "RET" #'exit-minibuffer
      :i "C-n" #'completion-at-point)

(map! :map evil-ex-search-keymap :after evil
      :n "j"   #'next-history-element
      :n "k"   #'previous-history-element
      :n "/"   #'previous-matching-history-element
      :n "RET" #'exit-minibuffer)

(map! :map vertico-map :after vertico
      :n "j"   #'next-history-element
      :n "k"   #'previous-history-element
      :n "/"   #'previous-matching-history-element
      :n "RET" #'vertico-exit
      :i "C-n" #'next-line-or-history-element
      :i "C-p" #'previous-line-or-history-element)

(map! :map vertico-map
      :im "C-w" #'vertico-directory-delete-word ;; HACK :: must bind again (smarter C-w)
      :im "C-d" #'consult-dir
      :im "C-f" #'consult-dir-jump-file)

(map! :map company-mode-map :after company
      :i "C-n" #'company-complete)

(map! :map comint-mode-map :after comint
      :i "C-r" #'comint-history-isearch-backward-regexp)

;; not defined :(
(map! :map cider-repl-mode-map :after cider-repl
      :n "C-j" #'cider-repl-next-prompt
      :n "C-k" #'cider-repl-previous-prompt
      :n "C-n" #'cider-repl-next-input
      :n "C-p" #'cider-repl-previous-input
      :i "C-r" #'cider-repl-previous-matching-input)
;; completion & minibuffer:1 ends here

;; [[file:config.org::*completion & minibuffer][completion & minibuffer:2]]
;; HACK :: '(1) since evil-complete-previous-func expects an arg.
(setq evil-complete-previous-minibuffer-func
      #'(lambda () (apply evil-complete-previous-func '(1))))
;; completion & minibuffer:2 ends here

;; [[file:config.org::*editing][editing:1]]
(map! :after evil
      :nm "&"   #'async-shell-command ;; consistent with dired, shell...
      :n  "L"   #'newline-and-indent
      :n  "_"   (cmd! (evil-use-register ?_)
		      (call-interactively #'evil-delete))

      ;; more sensible & ergonomic than `C-x/C-a', `+-' in vim is useless anyways.
      :n  "+"   #'evil-numbers/inc-at-pt
      :n  "-"   #'evil-numbers/dec-at-pt
      :n  "g+"  #'evil-numbers/inc-at-pt-incremental
      :n  "g-"  #'evil-numbers/dec-at-pt-incremental)
;; editing:1 ends here

;; [[file:config.org::*editing][editing:2]]
(define-key! key-translation-map "C-h" "DEL")
;; editing:2 ends here

;; [[file:config.org::*editing][editing:3]]
(map! :map evil-org-mode-map :after evil-org
      :n "gj"  #'evil-next-visual-line
      :n "gk"  #'evil-previous-visual-line

      :n "C-j" #'org-next-visible-heading
      :n "C-k" #'org-previous-visible-heading)
;; editing:3 ends here

;; [[file:config.org::*editing][editing:4]]
(add-hook! 'doom-escape-hook #'delete-other-windows)

(map! :after evil
      :nm "C-w" #'next-window-any-frame)
;; editing:4 ends here

;; [[file:config.org::*embrace emacs][embrace emacs:1]]
(define-key! [remap evil-ex] #'execute-extended-command)

(map! :after evil
      :n "Q" #'u/query-replace-regexp-op)

(evil-define-operator u/query-replace-regexp-op (beg end type)
  "make (anzu)`query-replace-regexp' into an operator acting only on defined region."
  :repeat nil
  (interactive "<R>")
  (save-excursion
   (goto-char end)
   (set-mark (point))
   (goto-char beg)
   (condition-case nil
       (call-interactively #'anzu-query-replace-regexp)
     (t (deactivate-mark)))))
;; embrace emacs:1 ends here

;; [[file:config.org::*embrace emacs][embrace emacs:2]]
(global-anzu-mode)
(define-key! [remap query-replace] #'anzu-query-replace)
(define-key! [remap query-replace-regexp] #'anzu-query-replace-regexp)
;; embrace emacs:2 ends here

;; [[file:config.org::*no visual selections][no visual selections:1]]
(define-key! [remap evil-visual-char] #'ignore)
(define-key! [remap evil-visual-line] #'ignore)
;; no visual selections:1 ends here

;; [[file:config.org::*no visual selections][no visual selections:2]]
(map! :map 'override
      :nm "v" #'basic-save-buffer
      :nm "V" #'find-file)
;; no visual selections:2 ends here

;; [[file:config.org::*surround][surround:1]]
(map! :after evil
      :n "s" #'evil-surround-region
      :n "S" #'evil-Surround-region)

(after! evil-surround
  (add-to-list 'evil-surround-pairs-alist '(?` . ("`" . "`")))

  (add-hook! 'org-mode-hook :local
    (add-to-list 'evil-surround-pairs-alist '(?~ . ("~" . "~")))))
;; surround:1 ends here

;; [[file:config.org::*smartparens][smartparens:1]]
(after! smartparens
  (setq sp-ignore-modes-list '()) ;; disable nowhere (consistency!)
  (->> (sp-local-pair "~" "~")
   (sp-with-modes 'org-mode)))
;; smartparens:1 ends here

;; [[file:config.org::*lispy(ville): editing lisp in vim][lispy(ville): editing lisp in vim:1]]
(add-hook! '(emacs-lisp-mode-hook
	     lisp-mode-hook
	     clojure-mode-hook
	     cider-repl-mode-hook)
	   #'lispyville-mode)

;; call help on `lispyville-set-key-theme' to see what is bound.
(after! lispyville
  (lispyville-set-key-theme '(operators
                              insert
                              c-w
                              c-u
                              prettify
                              text-objects
                              commentary
                              slurp/barf-lispy)))
;; lispy(ville): editing lisp in vim:1 ends here

;; [[file:config.org::*lispy(ville): editing lisp in vim][lispy(ville): editing lisp in vim:2]]
(map! :map lispyville-mode-map :after lispyville
      :nm "H" #'lispyville-raise-list

      :nm "(" #'lispyville-backward-up-list
      :nm ")" #'lispyville-up-list)
;; lispy(ville): editing lisp in vim:2 ends here

;; [[file:config.org::*harpoon][harpoon:1]]
(use-package! harpoon
  :config
  (setq harpoon-separate-by-branch nil) ;; simple repos
  (map! :map 'override
	:nm "M-1" #'harpoon-go-to-1
	:nm "M-2" #'harpoon-go-to-2
	:nm "M-3" #'harpoon-go-to-3
	:nm "M-4" #'harpoon-go-to-4

	:nm "M-6" (cmd! (switch-to-buffer next-error-last-buffer)))

  (map! :n "M" #'harpoon-add-file) ;; works only in file-visiting-buffers

  (map! :leader "M" #'harpoon-toggle-file)

  ;; exit like in help, magit, dired...
  (map! :map harpoon-mode-map :after harpoon
        :nm "q" #'kill-current-buffer)

  ;; show abs. line numbers to indicate the bindings.
  (setq-hook! 'harpoon-mode-hook display-line-numbers t))
;; harpoon:1 ends here

;; [[file:config.org::*harpoon][harpoon:2]]
(map! :map 'override
      :nm "<tab>" #'evil-switch-to-windows-last-buffer) ;; HACK :: must be <tab> not TAB to properly override

 ;; +org/toggle-fold ins incomplete (don't work with org-blocks/ LOG)
(define-key! [remap +org/toggle-fold] #'org-cycle)
;; harpoon:2 ends here

;; [[file:config.org::*occur: emacs interactive grep][occur: emacs interactive grep:1]]
(map! :map occur-mode-map :after replace
      :n "q" #'quit-window) ;; consistent with other read-only modes (magit, dired, docs...)

(map! :after evil
      :nm "g/"  #'occur)
;; occur: emacs interactive grep:1 ends here

;; [[file:config.org::*dired][dired:1]]
(after! dired
;; dired:1 ends here

;; [[file:config.org::*dired][dired:2]]
;; prevent hidden edits
(add-hook! 'wdired-mode-hook
  (dired-hide-details-mode -1)
  (dired-omit-mode -1))

(add-hook! 'dired-mode-hook '(dired-hide-details-mode dired-omit-mode))

(map! :map dired-mode-map :localleader :after dired-x
      :desc "dired-hide-details" "h" (cmd! (call-interactively #'dired-omit-mode)
					   (call-interactively #'dired-hide-details-mode)))


;; open graphical files externally
(setq dired-open-extensions (mapcan (lambda (pair)
                                      (let ((extensions (car pair))
                                            (app (cdr pair)))
                                        (mapcar (lambda (ext)
                                                  (cons ext app))
                                                extensions)))
                                    '((("mkv" "webm" "mp4" "mp3") . "mpv")
                                      (("pdf")                    . "zathura")
                                      (("gif" "jpg" "png")        . "feh")
                                      (("docx" "odt" "odf")       . "libreoffice")))
      dired-recursive-copies 'always
      dired-recursive-deletes 'always
      dired-no-confirm '(uncompress move copy)
      dired-omit-files "^\\..*$")

(map! :map dired-mode-map :after dired
      :n "&" #'async-shell-command ;; same as evil-normal-mode binding.
      :n "!" #'dired-do-async-shell-command ;; always use async
      :m "h" #'dired-up-directory) ;; HACK :: must be 'm' (otherwise also binds in 'wdired-mode')

;; try dired-open fn's (no success => call: `dired-find-file')
(define-key! [remap dired-find-file] #'dired-open-file)
;; dired:2 ends here

;; [[file:config.org::*archive file][archive file:1]]
(defvar u/archive-dir "~/Archive/")

(defun u/dired-archive ()
  "`mv' marked file/s to: `u/archive-dir'/{relative-filepath-to-HOME}/{filename}"
  (interactive)

  (mapc (lambda (file)
          (let* ((dest (file-name-concat u/archive-dir
					 (concat (->> "~/"
						      (file-relative-name file)
						      file-name-sans-extension)
						 "_archived_"
						 (format-time-string "%F_T%H-%M-%S")
						 (when (file-name-extension file)
						   (->> file
							file-name-extension
							(concat "."))))))
                 (dir (file-name-directory dest)))

            (unless (file-exists-p dir)
              (make-directory dir t))
            (rename-file file dest 1)))
        (dired-get-marked-files nil nil))

  (revert-buffer))

(map! :map dired-mode-map :localleader :after dired
      "a" #'u/dired-archive)
;; archive file:1 ends here

;; [[file:config.org::*archive file][archive file:2]]
)
;; archive file:2 ends here

;; [[file:config.org::*org][org:1]]
(after! org
;; org:1 ends here

;; [[file:config.org::*options][options:1]]
(add-hook! 'org-mode-hook '(visual-line-mode
                            org-fragtog-mode
                            rainbow-mode
                            laas-mode
                            +org-pretty-mode
                            org-appear-mode))

(setq-hook! 'org-mode-hook warning-minimum-level :error) ;; prevent frequent popups of *warning* buffer

(setq org-use-property-inheritance t
      org-reverse-note-order t ;; like stack
      org-startup-with-latex-preview nil
      org-startup-with-inline-images t
      org-startup-indented t
      org-startup-numerated t
      org-startup-align-all-tables t
      org-list-allow-alphabetical t ;; alphabetical are useful for lists without ordering if you later want to reference an item (like case (a), case (b).)
      org-tags-column 0		    ;; don't align tags
      org-fold-catch-invisible-edits 'smart
      org-refile-use-outline-path 'full-file-path
      org-refile-allow-creating-parent-nodes 'confirm
      org-use-sub-superscripts '{}
      org-fontify-quote-and-verse-blocks t
      org-fontify-whole-block-delimiter-line t
      doom-themes-org-fontify-special-tags t
      org-num-max-level 3 ;; don't nest deeply
      org-hide-leading-stars t
      org-appear-autoemphasis t
      org-appear-autosubmarkers t
      org-appear-autolinks t
      org-appear-autoentities t
      org-appear-autokeywords t
      org-appear-inside-latex nil
      org-hide-emphasis-markers t
      org-pretty-entities t
      org-pretty-entities-include-sub-superscripts t
      org-list-demote-modify-bullet '(("-" . "-")
				      ("1." . "1."))
      org-blank-before-new-entry '((heading . nil)
				   (plain-list-item . nil))
      org-src-ask-before-returning-to-edit-buffer nil) ;; don't annoy me

;; flycheck full of errors, since it only reads partial buffer.
(add-hook! 'org-src-mode-hook (flycheck-mode -1))
;; options:1 ends here

;; [[file:config.org::*options][options:2]]
(defadvice! u/insert-newline-above (fn &rest args)
  "pad newly inserted heading with newline unless is todo-item.

since i often have todolists , where i don't want the newlines.  newlines are for headings that have a body of text."
  :after #'+org/insert-item-below
  (when (and (org-at-heading-p)
             (not (org-entry-is-todo-p)))
    (+evil/insert-newline-above 1)))

(defadvice! u/insert-newline-below (fn &rest args)
  :after #'+org/insert-item-above
  (when (and (org-at-heading-p)
             (not (org-entry-is-todo-p)))
    (+evil/insert-newline-below 1)))
;; options:2 ends here

;; [[file:config.org::*symbols][symbols:1]]
(add-hook! 'org-mode-hook '(org-superstar-mode
			      prettify-symbols-mode))

(setq org-superstar-headline-bullets-list "●")

(setq org-superstar-item-bullet-alist '((?- . "─")
                                        (?* . "─")
                                        (?+ . "⇒")))

(appendq! +ligatures-extra-symbols '(:em_dash       "—"
                                     :ellipses      "…"
                                     :arrow_right   "→"
                                     :arrow_left    "←"
                                     :arrow_lr      "↔"))

(add-hook! 'org-mode-hook
  (appendq! prettify-symbols-alist '(("--" . "–")
				       ("---" . "—")
				       ("->" . "→")
				       ("=>" . "⇒")
				       ("<=>" . "⇔"))))
;; symbols:1 ends here

;; [[file:config.org::*org/keybindings][org/keybindings:1]]
(map! :map org-mode-map :after org
	:localleader
	"\\" #'org-latex-preview
	"z"  #'org-add-note
	:desc "toggle-checkbox" "["  (cmd! (let ((current-prefix-arg 4))
                                           (call-interactively #'org-toggle-checkbox))))
;; org/keybindings:1 ends here

;; [[file:config.org::*babel][babel:1]]
(setq org-babel-default-header-args '((:session  . "none")
					(:results  . "replace")
					(:exports  . "code")
					(:cache    . "no")
					(:noweb    . "yes")
					(:hlines   . "no")
					(:tangle   . "no")
					(:mkdirp   . "yes")
					(:comments . "link"))) ;; important for when wanting to retangle
;; babel:1 ends here

;; [[file:config.org::*clock][clock:1]]
(setq org-clock-out-when-done t
	org-clock-persist t
	org-clock-into-drawer t)
;; clock:1 ends here

;; [[file:config.org::*task states][task states:1]]
;; ! => save timestamp on statchange
;; @ => save timestamp on statchange & add note associated with change to LOG.
(setq org-todo-keywords '((sequence
                           "[ ](t)"
                           "[@](e)"
                           "[?](?!)"
                           "[-](-@)"
                           "[>](>@)"
                           "[=](=@)"
                           "[&](&@)"
                           "|"
                           "[x](x!)"
                           "[\\](\\!)")))

(setq org-todo-keyword-faces '(("[@]" . (bold +org-todo-project))
			       ("[ ]" . (bold org-todo))
			       ("[-]" . (bold +org-todo-active))
			       ("[>]" . (bold +org-todo-onhold))
			       ("[?]" . (bold +org-todo-onhold))
			       ("[=]" . (bold +org-todo-onhold))
			       ("[&]" . (bold +org-todo-onhold))
			       ("[\\]" . (bold org-done))
			       ("[x]" . (bold org-done))))
;; task states:1 ends here

;; [[file:config.org::*task states][task states:2]]
(setq org-log-done 'time
	org-log-repeat 'time
	org-todo-repeat-to-state "[ ]"
	org-log-redeadline 'time
	org-log-reschedule 'time
	org-log-into-drawer "LOG") ;; more concise & modern than: LOGBOOK

(setq org-priority-highest 1
	org-priority-lowest 3)

(setq org-log-note-headings '((done . "note-done: %t")
			      (state . "state: %-3S -> %-3s %t") ;; NOTE :: the custom task-statuses are all 3- wide
			      (note . "note: %t")
			      (reschedule . "reschedule: %S, %t")
			      (delschedule . "noschedule: %S, %t")
			      (redeadline . "deadline: %S, %t")
			      (deldeadline . "nodeadline: %S, %t")
			      (refile . "refile: %t")
			      (clock-out . "")))
;; task states:2 ends here

;; [[file:config.org::*capture templates][capture templates:1]]
(setq org-directory "~/Documents/org/")

  (defvar u/journal-dir (file-name-concat "~/Documents/journal/")
    "dir for daily captured journal files")

  (defvar u/literature-dir "~/Documents/literature"
    "literature sources and captured notes")

  (defvar u/literature-notes-dir (file-name-concat u/literature-dir "notes/")
    "note files for each literature source")

  (defvar u/wiki-dir "~/Documents/wiki/"
    "personal knowledge base directory :: cohesive, structured, standalone articles/guides.
(blueprints and additions to these articles are captured into 'org-directory/personal/notes.org',
and the later reviewed and merged into the corresponding article of the wiki.")

  (defvar u/doct-projects-default-templates '(u/doct-projects-task-template
					      u/doct-projects-event-template
					      u/doct-projects-note-template))

  (defvar u/doct-projects `(("cs" :keys "c"
                             :templates ,u/doct-projects-default-templates
                             :children (("ti"   :keys "t")
					("an2"  :keys "a")
					("ph1"  :keys "p")
					("spca" :keys "s" :templates (u/doct-projects-cc-src-template))
					("nm"   :keys "n" :templates (u/doct-projects-cc-src-template))))
                            ("personal" :keys "p" :templates ,u/doct-projects-default-templates)
                            ("config"   :keys "f" :templates ,u/doct-projects-default-templates))
    "same syntax as doct,  except for the key-value-pair: `:templates LIST`,
 where LIST is a list of functions with signature: `(PATH) -> VALID-DOCT-TEMPLATE`
 where PATH is to be generated by 'u/doct-projects-file'
 where TEMPLATE is a valid 'doct-capture-template'.
':templates' is inherited by the parent-group and if present in a childgroup it appends the
   additionally defined templates.")

  (defun u/doct-journal-file (&optional time)
    "returns a structured filename based on the current date.
eg: journal_2024-11-03.org
TIME :: time in day of note to return. (default: today)"
    (->> (current-time)
	 (or time)
	 (format-time-string "%F")
	 (format "journal_%s.org")
	 (file-name-concat u/journal-dir)))

  (defun u/doct-projects-file (type path)
    "TYPE :: 'agenda | 'notes"
    (->> type
	 symbol-name
	 (format "%s.org")
	 (file-name-concat org-directory path)))

  (defun u/doct-projects-task-template (path)
    (list "task"
          :keys "t"
          :file (u/doct-projects-file 'agenda path)
          :headline "inbox"
          :prepend t
          :empty-lines-after 1
          :template '("* [ ] %^{title}%?")))

  (defun u/doct-projects-event-template (path)
    (list "event"
          :keys "e"
          :file (u/doct-projects-file 'agenda path)
          :headline "events"
          :prepend t
          :empty-lines-after 1
          :template '("* [@] %^{title}%?"
                      "%^T"
                      ":PROPERTIES:"
                      ":REPEAT_TO_STATE: [@]" ; NOTE :: in case is made repeating
                      ":location: %^{location}"
                      ":material: %^{material}"
                      ":END:")))

  (defun u/doct-projects-note-template (path)
    (list "note"
          :keys "n"
          :file (u/doct-projects-file 'notes path)
          :prepend t
          :empty-lines-after 1
          :template '("* %^{title} %^g"
                      ":PROPERTIES:"
                      ":created: %U"
                      ":END:"
                      "%?")))

  (defun u/doct-projects-cc-src-template (path)
    "for quickly implementing/testing ideas (like a scratchpad, but have all
  our code-snippets in a single literate document, instead of creating a new file each time).  choose either c or c++."

    (list "note: src cc"
          :keys "s"
          :file (u/doct-projects-file 'notes path)
          :prepend t
          :empty-lines 1
          :template '("* %^{title} :%^{lang|C|C|cpp}:"
                      ":PROPERTIES:"
                      ":created: %U"
                      ":END:"
                      "#+begin_src %\\2"
                      "int main() {"
                      "        %?"
                      "}"
                      "#+end_src")))

  (defun u/doct-projects-expand-templates (projects &optional inherited-templates parent-path)
    "PROJECTS :: `u/doct-projects'
PARENT-PATH :: nil (used for recursion) "
    (mapcar (lambda (project)
              (let* ((tag (car project))
                     (props (cdr project))
                     (key (plist-get props :keys))
                     (self `(,tag :keys ,key))
                     (children (plist-get props :children))
                     (templates (append inherited-templates
					(plist-get props :templates)))
                     (path (file-name-concat parent-path tag)))

		(append self
			(if children
                            ;; HAS CHILDREN => is project-node => recursivly expand children
                            (list :children
                                  (append (u/doct-projects-expand-templates (list self)
									    templates)
                                          (u/doct-projects-expand-templates children
									    templates
									    path)))

                          ;; NO CHILDREN => is leaf-node => instantiate templates
                          (list :children
				(mapcar (lambda (fn-sym)
                                          (funcall fn-sym path))
                                        templates))))))
            projects))

  (setq org-capture-templates
	(doct `(;; PROJECT TEMPLATES
		,@(u/doct-projects-expand-templates u/doct-projects)

		;; NON-PROJECT TEMPLATES
		("journal"
		 :keys "j"

		 :file (lambda ()
			 (u/doct-journal-file))

		 :title (lambda ()
                          (->> (format-time-string "journal: %A, %e. %B %Y")
			       downcase))

		 :children (("journal init"
                             :keys "j"
                             :type plain
                             :template  ("#+title:  %{title}"
					 "#+author: %(user-full-name)"
					 "#+email:  %(message-user-mail-address)"
					 "#+date:   %<%F>"
					 "#+filetags: :journal:"
					 ""
					 "* goals"
					 "- [ ] %?"
					 ""
					 "* agenda"
					 "** [ ] "
					 ""
					 "* notes"))

                            ("note"
                             :keys "n"
                             :headline "notes"
                             :prepend t
                             :empty-lines-after 1
                             :template ("* %^{title}"
					":PROPERTIES:"
					":created: %U"
					":END:"
					"%?"))

                            ("yesterday review"
                             :keys "y"
                             :unnarrowed t

                             :file (lambda ()
				     (->> (days-to-time 1)
					  (time-subtract (current-time))
					  u/doct-journal-file))

                             :template ("* gratitude"
					"- %?"
					""
					"* reflection"
					"-"))))

		("literature"
		 :keys "l"

		 :file (lambda () (read-file-name "file: " u/literature-notes-dir))

		 :children (("add to readlist"
                             :keys "a"
                             :file ,(file-name-concat u/literature-dir "readlist.org")
                             :headline "inbox"
                             :prepend t
                             :template ("* [ ] %^{title}"))

                            ("init source"
                             :keys "i"

                             :file (lambda ()
                                     (->> (concat (->> (read-from-minibuffer "short title: ")
						       (replace-regexp-in-string " " "_"))
						  ".org")
					  (file-name-concat u/literature-notes-dir)))

                             :type plain

                             :template ("#+title:  %^{full title}"
					"#+author: %(user-full-name)"
					"#+email:  %(message-user-mail-address)"
					"#+date:   %<%F>"
					"#+filetags: :literature:%^g"
					""
					"* [-] %\\1%?"
					":PROPERTIES:"
					":title:  %\\1"
					":author: %^{author}"
					":year:   %^{year}"
					":type:   %^{type|book|book|textbook|book|paper|article|audiobook|podcast}"
					":pages:  %^{pages}"
					":END:")

                             :hook (lambda () (message "change task-state in readlist.org!")))

                            ("quote"
                             :keys "q"
                             :headline "quotes"
                             :empty-lines-before 1

                             :template ("* %^{title} [pg: %^{page}]"
					":PROPERTIES:"
					":created: %U"
					":END:"
					"#+begin_quote"
					"%?"
					"#+end_quote"))

                            ("note: literary"
                             :keys "l"
                             :headline "literature notes"
                             :empty-lines-before 1
                             :template ("* %^{title} [pg: %^{page}] %^g"
					":PROPERTIES:"
					":created: %U"
					":END:"
					"%?"))

                            ("note: transient"
                             :keys "t"
                             :headline "transient notes"
                             :empty-lines-before 1
                             :template ("* %^{title} %^g"
					":PROPERTIES:"
					":created: %U"
					":END:"
					"%?"))

                            ("summarize"
                             :keys "s"
                             :headline "summary"
                             :unnarrowed t
                             :type plain
                             :template ("%?")
                             :hook (lambda ()
                                     (message "change task-state!: TODO -> DONE")))))))) ;; in order to log finishing date
;; capture templates:1 ends here

;; [[file:config.org::*agenda][agenda:1]]
(add-hook! 'org-agenda-mode-hook #'org-super-agenda-mode)

;; NOTE :: archive based on relative file path
(setq org-archive-location (file-name-concat u/archive-dir
					     "org"
					     "%s::")

	org-agenda-files (append (when (file-exists-p org-directory)
				   (directory-files-recursively org-directory
								org-agenda-file-regexp
								t))
				 ;; include tasks from {today's, yesterday's} journal's agenda
				 (->> (days-to-time 1)
				      (time-subtract (current-time))
				      u/doct-journal-file
				      (list (u/doct-journal-file))))

	org-agenda-skip-scheduled-if-done t
	;; org-agenda-sticky t
	org-agenda-skip-deadline-if-done t
	org-agenda-include-deadlines t
	org-agenda-tags-column 0
	org-agenda-block-separator ?─
	org-agenda-breadcrumbs-separator "…"
	org-agenda-compact-blocks nil
	org-agenda-show-future-repeats nil
	org-deadline-warning-days 3
	org-agenda-time-grid nil
	org-capture-use-agenda-date t)
;; agenda:1 ends here

;; [[file:config.org::*agenda][agenda:2]]
(defadvice! u/add-newline (fn &rest args)
  "Separate dates in 'org-agenda' with newline."
  :around #'org-agenda-format-date-aligned
  (->> (apply fn args)
       (concat "\n")))
;; agenda:2 ends here

;; [[file:config.org::*agenda][agenda:3]]
(setq org-agenda-todo-keyword-format "%-3s"
      org-agenda-scheduled-leaders '("" "<< %1dd")

      org-agenda-deadline-leaders '("─────"
				    ">> %1dd"
				    "<< %1dd")

      org-agenda-prefix-format '((agenda . "%-20c%-7s%-7t") ;; all columns separated by minimum 2 spaces
				 (todo   . "%-20c%-7s%-7t")
				 (tags   . "%-20c%-7s%-7t")
				 (search . "%-20c%-7s%-7t")))
;; agenda:3 ends here

;; [[file:config.org::*org roam][org roam:1]]
(setq org-roam-directory u/wiki-dir)
;; org roam:1 ends here

;; [[file:config.org::*org roam][org roam:2]]
)
;; org roam:2 ends here

;; [[file:config.org::*dictionary][dictionary:1]]
(after! dictionary
  (setq dictionary-server "dict.org"
        dictionary-default-dictionary "*"))
;; dictionary:1 ends here

;; [[file:config.org::*devdocs][devdocs:1]]
(after! devdocs
  (setq devdocs-window-select t))

(setq-hook! 'java-mode-hook devdocs-current-docs '("openjdk~17"))
(setq-hook! 'c++-mode-hook devdocs-current-docs '("cpp" "eigen3"))
(setq-hook! 'c-mode-hook devdocs-current-docs '("c"))
(setq-hook! '(cider-mode-hook
	      cider-repl-mode-hook)
  devdocs-current-docs '("clojure~1.11"))
;; devdocs:1 ends here

;; [[file:config.org::*whisper: transcription][whisper: transcription:1]]
(evil-define-operator u/reformat-prose (beg end)
  "we write all lowercase, all the time (to make the text more monotone, such that it's value will
speak more for it's self).  using the technical document convention of double space full stops for
legibility."
  (save-excursion
    (downcase-region beg end)
    (repunctuate-sentences t beg end)))

(add-hook! 'whisper-after-transcription-hook (u/reformat-prose (point-min) (point-max)))

(map! :leader "X" #'whisper-run)
;; whisper: transcription:1 ends here

;; [[file:config.org::*vertico: minibuffer completion][vertico: minibuffer completion:1]]
(vertico-flat-mode)
;; vertico: minibuffer completion:1 ends here

;; [[file:config.org::*nov: ebooks][nov: ebooks:1]]
(use-package! nov
  :mode ("\\.epub\\'" . nov-mode)
  :config
  (setq nov-variable-pitch t
        nov-text-width t)
  (advice-add 'nov-render-title :override #'ignore) ;; using modeline...

  (map! :map (nov-mode-map nov-button-map)
        "SPC" nil
        "C-SPC" nil
        :n "q" #'kill-current-buffer
        :n "o" #'nov-goto-toc

        ;; next/previous page
        :n "<next>" #'nov-scroll-up
        :n "<prior>" #'nov-scroll-down)

  (add-hook! 'nov-mode-hook
    (visual-fill-column-mode)
    (visual-line-mode)

    (setq-local next-screen-context-lines 0
                line-spacing 2)

    ;; HACK :: need to unset
    (setq-local global-hl-line-mode nil)
    (hl-line-mode -1)))
;; nov: ebooks:1 ends here

;; [[file:config.org::*company: code completion][company: code completion:1]]
(after! company
  (setq company-minimum-prefix-length 0
        company-idle-delay nil ;; only show menu when explicitly activated
        company-show-quick-access t))
;; company: code completion:1 ends here

;; [[file:config.org::*yas: snippets][yas: snippets:1]]
(setq yas-triggers-in-field t)
;; yas: snippets:1 ends here

;; [[file:config.org::*file templates][file templates:1]]
(set-file-templates!
 '(org-mode :trigger "header")
 '(prog-mode :trigger "header")
 '(makefile-gmake-mode :ignore t))
;; file templates:1 ends here

;; [[file:config.org::*shell][shell:1]]
(setq shell-command-prompt-show-cwd t
      async-shell-command-buffer 'new-buffer)

(setq comint-process-echoes t)

(set-lookup-handlers! 'shell-mode :documentation '+sh-lookup-documentation-handler)

(add-to-list 'evil-normal-state-modes 'shell-mode)
;; shell:1 ends here

;; [[file:config.org::*lsp][lsp:1]]
(after! lsp-mode
  (setq lsp-restart 'ignore))
;; lsp:1 ends here

;; [[file:config.org::*harpoon bugfix (PR open, override until accepted)][harpoon bugfix (PR open, override until accepted):1]]
(after! harpoon
  (defadvice! u/harpoon-go-to (line-number)
    "Go to specific file on harpoon (by line order). LINE-NUMBER: Line to go."
    :override #'harpoon-go-to
    (require 'project)

    (let* ((harpoon-mode-p (eq major-mode 'harpoon-mode))

           (harpoon-file (if harpoon-mode-p
                             (file-truename (buffer-file-name))
                           (harpoon--file-name)))

           (file-name (s-replace-regexp "\n" ""
                                        (with-temp-buffer
                                          (insert-file-contents-literally harpoon-file)
                                          (goto-char (point-min))
                                          (forward-line (- line-number 1))
                                          (buffer-substring-no-properties (line-beginning-position)
                                                                          (line-end-position)))))

           (full-file-name (if (and (fboundp 'project-root)
                                    (harpoon--has-project))
                               (concat (or harpoon--project-path
                                           (harpoon-project-root-function))
                                       file-name)

                             file-name)))
      (if harpoon-mode-p
          (harpoon-find-file file-name)

        (if (file-exists-p full-file-name)
            (find-file full-file-name)

          (message (concat full-file-name " not found."))))))

  (defadvice! u/harpoon-find-file (&optional file-name)
    "Visit file on `harpoon-mode'."
    :override #'harpoon-find-file
    (interactive)

    (let* ((file-name (or file-name
                          (buffer-substring-no-properties (point-at-bol)
							  (point-at-eol))))
           (full-file-name (concat harpoon--project-path
				   file-name)))

      (if (file-exists-p full-file-name)
          (progn (save-buffer)
                 (kill-buffer)
                 (find-file full-file-name))

        (message "[harpoon] File %s not found." full-file-name)))))
;; harpoon bugfix (PR open, override until accepted):1 ends here
