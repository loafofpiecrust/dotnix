;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; References:
;; https://github.com/rougier/elegant-emacs

;; Let me load my custom packages.
(add-load-path! "~/.config/doom/custom")

;; Load custom themes from the "themes" folder here.
(setq custom-theme-directory (expand-file-name "~/.config/doom/themes"))

;; Make shell commands run faster and more reliably using bash.
(setq shell-file-name (executable-find "bash"))

(menu-bar-mode (if (eq system-type 'darwin) t -1))

;; Make emacs backgrounds partially transparent!
;; It's finally here, as of 2022!
;; Ensure no transparency for posframes, only the parent system frame.
;; (add-to-list 'initial-frame-alist '(alpha-background . 80))
;; (add-to-list 'minibuffer-frame-alist '(alpha-background . 100))

(after! vertico-posframe
  (defun posframe-poshandler-frame-top-center-margin (info)
    "Top center of the frame, offset from the top by a bit"
    (cons (/ (- (plist-get info :parent-frame-width)
                (plist-get info :posframe-width))
             2)
          32))
  (setq! vertico-posframe-min-width 80
         vertico-posframe-parameters '((left-fringe . 8) (right-fringe . 8))
         vertico-posframe-poshandler 'posframe-poshandler-frame-top-center-margin))

(use-package! gsettings)

(defun +snead/load-theme (timesym)
  (setq catppuccin-flavor (if (eq timesym 'night) 'macchiato 'latte))
  (catppuccin-reload))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq! catppuccin-flavor
;;(if (and (gsettings-available?)
;;(string= "prefer-dark"
;;(gsettings-get "org.gnome.desktop.interface" "color-scheme")))
;;'macchiato
;;'latte))

(use-package! modus-themes
  :after json
  :init
  (unless (eq system-type 'darwin)
    (defvar +snead/light (json-read-file "~/.cache/colors/light.json"))
    (defvar +snead/dark (json-read-file "~/.cache/colors/dark.json"))
    (setq! modus-themes-italic-constructs t
           modus-themes-mixed-fonts t
           modus-operandi-palette-overrides
           `((bg-main ,(alist-get 'background +snead/light))
             (bg-dim ,(alist-get 'surface1 +snead/light))
             ;; Extra contrast by using pure black for text.
             (fg-main ,(alist-get 'brightwhite +snead/light))
             (fg-dim ,(alist-get 'comment +snead/light))
             (fg-alt ,(alist-get 'foreground +snead/light))
             (border ,(alist-get 'focus +snead/light))
             (red ,(alist-get 'red +snead/light))
             (red-intense ,(alist-get 'brightred +snead/light))
             (green ,(alist-get 'green +snead/light))
             (green-intense ,(alist-get 'brightgreen +snead/light))
             (yellow ,(alist-get 'yellow +snead/light))
             (yellow-intense ,(alist-get 'brightyellow +snead/light))
             (blue ,(alist-get 'blue +snead/light))
             (blue-cooler ,(alist-get 'blue +snead/light))
             (blue-intense ,(alist-get 'brightblue +snead/light))
             (magenta ,(alist-get 'magenta +snead/light))
             (magenta-intense ,(alist-get 'brightmagenta +snead/light))
             (cyan ,(alist-get 'cyan +snead/light))
             (cyan-intense ,(alist-get 'brightcyan +snead/light))
             (pink ,(alist-get 'magenta +snead/light)))
           modus-vivendi-tinted-palette-overrides
           `((bg-main ,(alist-get 'background +snead/dark))
             (bg-dim ,(alist-get 'surface1 +snead/dark))
             (fg-main ,(alist-get 'brightwhite +snead/dark))
             (fg-dim ,(alist-get 'comment +snead/dark))
             (fg-alt ,(alist-get 'foreground +snead/dark))
             (border ,(alist-get 'focus +snead/dark))
             (red ,(alist-get 'red +snead/dark))
             (red-intense ,(alist-get 'brightred +snead/dark))
             (green ,(alist-get 'green +snead/dark))
             (green-cooler ,(alist-get 'brightgreen +snead/dark))
             (green-intense ,(alist-get 'brightgreen +snead/dark))
             (yellow ,(alist-get 'yellow +snead/dark))
             (yellow-intense ,(alist-get 'brightyellow +snead/dark))
             (blue ,(alist-get 'blue +snead/dark))
             (blue-cooler ,(alist-get 'blue +snead/dark))
             (blue-intense ,(alist-get 'brightblue +snead/dark))
             (magenta ,(alist-get 'magenta +snead/dark))
             (magenta-intense ,(alist-get 'brightmagenta +snead/dark))
             (cyan ,(alist-get 'cyan +snead/dark))
             (cyan-intense ,(alist-get 'brightcyan +snead/dark))
             (pink ,(alist-get 'magenta +snead/dark))
             (string yellow-intense)
             (type green)
             (builtin magenta)
             (comment yellow)))))

(setq! doom-theme 'modus-operandi-tinted
       custom-safe-themes t)

(use-package! auto-dark
  :after doom-ui
  :config
  (setq! auto-dark-themes '((modus-vivendi-tinted) (modus-operandi-tinted)))
  (auto-dark-mode))

(setq doom-gruvbox-brighter-comments nil
      doom-peacock-brighter-comments t
      doom-monokai-classic-brighter-comments t
      doom-acario-light-brighter-comments t
      doom-one-light-brighter-comments t
      doom-dracula-brighter-comments nil)



;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; Symbol test: _ -> => , . `' "" O0l1*#
(setq doom-font (if (eq system-type 'darwin)
                    (font-spec :family "Hack Nerd Font" :size 14)
                  (font-spec :family "Hack Nerd Font FC Ligatured CCG" :size 15))
      doom-variable-pitch-font (if (eq system-type 'darwin) (font-spec :family "Overpass" :size 16) (font-spec :family "sans" :size 18))
      doom-unicode-font doom-font
      ;; doom-unicode-font (font-spec :family "Symbola monospacified for Source Code Pro" :size 15)
      ;; These fonts were fucking up display of math symbols! Remove them!
      ;; doom-unicode-extra-fonts nil
      )

;; Avoid extra tall title bar on mac
(when (eq system-type 'darwin)
  (add-hook 'doom-after-init-hook (lambda () (tool-bar-mode 1) (tool-bar-mode 0))))

;; Use org mode for the scratch buffer.
(setq-default doom-scratch-initial-major-mode 'org-mode)

;; Give each line some room to breathe.
(setq-default line-spacing 3)

(defvar +snead/frame-border-width 3)
(defvar +snead/frame-fringe 8)

(after! hide-mode-line
  (setq-default hide-mode-line-format nil)
  ;; (setq-hook! 'hide-mode-line-mode-hook header-line-format nil)
  )

;; Remove the fringe from all windows, unless you're visiting a file.
;; In that case, the fringe is very useful for git status and error information.
(defun +snead/add-fringe (&optional no-fringe)
  (setq-local left-fringe-width (if no-fringe 0 4)
              right-fringe-width (if no-fringe 0 4)))

(defun +snead/remove-fringe ()
  (interactive)
  (set-fringe-mode 0))

(defvar +snead/fringe-deny-modes '(pdf-view-mode))
(defun +snead/set-fringe ()
  "Add a fringe to windows carrying file-visiting buffers."
  (when (and buffer-file-name
             (not (memq major-mode +snead/fringe-deny-modes)))
    (+snead/add-fringe)))

;; (after! fringe
;;   (set-fringe-mode 0)
;;   (add-hook! '(exwm-mode-hook pdf-view-mode-hook) #'+snead/remove-fringe)
;;   ;; (add-hook 'after-change-major-mode-hook #'+snead/set-fringe)
;;   (add-hook 'vterm-mode-hook #'+snead/add-fringe))

(use-package! emacs
  :config
  (setq-default user-full-name "Shelby Snead"
                user-mail-address "shelby@snead.xyz"
                confirm-kill-processes nil
                confirm-kill-emacs nil
                truncate-lines nil
                scroll-margin 2
                ;; Inhibit auto-save messages because they're mostly distracting.
                auto-save-no-message t
                delete-by-moving-to-trash t
                x-stretch-cursor t
                ;; Trust all themes since I install few.
                custom-safe-themes t)

  (setq-hook! '(vterm-mode-hook eshell-mode-hook)
    truncate-lines nil)

  (appendq! initial-frame-alist '((left-fringe . 0)
                                  (right-fringe . 0))))

(after! scroll-bar
  ;; remove all scrollbars!
  (horizontal-scroll-bar-mode -1))

;; Add dividers between each window.
(after! frame
  (setq-default window-divider-default-right-width 5
                window-divider-default-bottom-width 5
                window-divider-default-places 'right-only))

;; Store various logins and things in a gpg file when necessary.
(after! auth-source
  (setq-default auth-sources '("~/.authinfo.gpg")))

;; Always show line numbers.
(after! display-line-numbers
  (setq-default display-line-numbers-type 'relative
                display-line-numbers-grow-only t))

(after! prog-mode
  ;; Consider each segment of a camelCase one word,
  (add-hook 'prog-mode-hook #'auto-fill-mode)
  (add-hook 'prog-mode-hook #'subword-mode)
  ;; Automatically wrap comments in code
  (setq-default comment-auto-fill-only-comments t))

;; Make calculator easy to access.
(map! :leader "oc" #'calc)
(after! calc
  (setq-default calc-symbolic-mode t))

;; Make calc compatible with evil mode, and add a nice menu on top!
(use-package! casual-calc
  :disabled
  :after calc evil-collection
  :init
  (evil-collection-init 'calc)
  ;; No need for insert mode in the calculator
  ;; (map! :n "i" 'casual-calc-tmenu)
  )

;; Support .calc files too!
(use-package! literate-calc-mode
  :commands (literate-calc-mode literate-calc-minor-mode)
  :mode (("\\.calc\\'" . literate-calc-mode))
  :init (map! :leader "tc" 'literate-calc-minor-mode))

;; Open urls with xdg-open so that app links open directly.
;; This let's me open zoommtg:// urls right into zoom.
(setq! browse-url-generic-program "xdg-open"
       browse-url-browser-function #'browse-url-generic)

(custom-set-faces!
  `(mixed-pitch-variable-pitch :family "sans" :height 1.2)
  `(fringe :background ,nil)
  `(olivetti-fringe :background ,nil)
  '(org-document-title :weight extra-bold :height 1.7)
  '(outline-1 :weight extra-bold :height 1.7)
  '(outline-2 :weight bold :height 1.4)
  '(outline-3 :weight bold :height 1.2)
  '(outline-4 :weight semi-bold :height 1.1)
  '(outline-5 :weight semi-bold :height 1.05)
  '(outline-6 :weight semi-bold :height 1.0)
  '((outline-7 outline-8 outline-9) :weight semi-bold)
  ;; Style markdown headers the same way.
  '(markdown-header-face-1 :inherit outline-1 :underline (:style line :color "grey"))
  '(markdown-header-face-2 :inherit outline-2)
  '(markdown-header-face-3 :inherit outline-3)
  '(markdown-header-face-4 :inherit outline-4)
  '(markdown-header-face-5 :inherit outline-5)
  ;; Not all themes provide this inheritance.
  '(org-level-1 :inherit outline-1 :underline (:style line :color "grey"))
  '(org-level-2 :inherit outline-2)
  '(org-level-3 :inherit outline-3)
  '(org-level-4 :inherit outline-4)
  '(org-level-5 :inherit outline-5)
  '(org-level-6 :inherit outline-6)
  ;; Make line numbers more visible on many themes.
  `(line-number :foreground ,nil :inherit org-tag)
  ;; Emacs 28 adds this new face with a different font for comments.
  ;; I want to retain the same font as normal code for now.
  `(fixed-pitch-serif :family ,nil)
  `(org-block-background :family ,doom-font)
  `(org-table :family ,doom-font)
  ;; Disable background color for highlighted parens
  ;; '(show-paren-match :background nil)
  ;; `(minibuffer-prompt :family ,nil)
  ;; '(pyim-page :height 1.1)
  )

;; Test for unicode icons (should be marked "seen" and "important")
;; neu          11:43:48        Information Technology... Received: INC0628880 – Fwd: Office 365 Transition Ridiculous
;; Pull exwm config from separate file.
;; (use-package! my-exwm-config
;;   :if (equal "t" (getenv "EMACS_EXWM")))

(after! unicode-fonts
  ;; Source Code Pro shares metrics with SF Mono and has full IPA.
  (push '("IPA Extensions" ("Source Code Pro"))
        unicode-fonts-block-font-mapping)
  (push '("Modifier Letter Small H" "Modifier Letter Small H"
          ("DejaVu Sans Mono"))
        unicode-fonts-overrides-mapping)
  ;;(setq unicode-fonts-fallback-font-list '("Symbola monospacified for Source Code Pro" "Source Code Pro"))
  ;; (if nil (setq unicode-fonts-restrict-to-fonts (append '("DejaVu Sans Mono"
  ;;                                                 "Noto Sans"
  ;;                                                 "Noto Sans Symbols"
  ;;                                                 "Noto Sans Symbols2"
  ;;                                                 "Noto Sans Cherokee"
  ;;                                                 "Source Code Pro"
  ;;                                                 ;;"Symbola monospacified for Source Code Pro"
  ;;                                                 "Noto Sans CJK JP"
  ;;                                                 "Noto Sans CJK SC"
  ;;                                                 "Noto Sans CJK TC")
  ;;                                               my/private-use-fonts)))
  )

;;;; Themes and color management
;; (use-package! ewal
;;   :after doom-themes
;;   :config (ewal-load-colors)
;;   :init
;;   ;; Use all 16 colors from our palette, not just the primary 8.
;;   (setq ewal-ansi-color-name-symbols '(black red green yellow blue magenta cyan white
;;                                        brightblack brightred brightgreen brightyellow
;;                                        brightblue brightmagenta brightcyan brightwhite)))

;; (use-package! ewal-doom-themes
;;   :after ewal
;;   :config
;;   (setq ewal-doom-vibrant-brighter-comments t))

;;;; org-mode adjustments
;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(after! org
  ;; Change some org display properties.
  (setq-default org-deadline-warning-days 10
                org-link-descriptive t
                org-startup-indented nil
                org-indent-indentation-per-level 1
                org-use-property-inheritance t
                org-list-allow-alphabetical t
                org-catch-invisible-edits 'smart
                org-ellipsis " ▾ "
                org-link-descriptive nil
                org-list-demote-modify-bullet '(("-" . "+") ("+" . "*") ("*" . "-"))
                ;; Adjust LaTeX display and export with tectonic.
                org-latex-compiler "xelatex"
                org-latex-pdf-process '("tectonic -Z shell-escape %f")
                org-latex-prefer-user-labels t
                org-log-done t
                org-highlight-latex-and-related '(native script entities)))

(after! org-superstar
  ;; Bullet symbols: ‣•◦⦾⦿✷🟆➤⮞⁕⊙ ⁖🜔🜕🜖🜗🝆🝎❯⁕✸✿✤✜◆∴∷
  (setq ;; org-superstar-headline-bullets-list '("∷" "✽" "✿" "✤" "✸" "❁" "✜")
   org-superstar-prettify-item-bullets t
   org-superstar-item-bullet-alist '((?* . ?‣)
                                     (?- . ?•)
                                     (?+ . ?◦))
   org-superstar-remove-leading-stars t))

(after! undo-tree
  (map! :map undo-tree-mode-map
        :leader "ou" 'undo-tree-visualize))

;; Make running commands through leader key shorter.
(map! :leader ";" 'execute-extended-command)

;; Add an easy mapping for exporting minibuffer results (especially from grep)
(map! :map minibuffer-mode-map "C-e" 'embark-export)

;; FIXME this doesn't quite work for embark-export windows
(map! :map compilation-mode-map
      :n "gq" 'kill-buffer-and-window)

;; I like using <u> for undo and <U> for redo. It's symmetrical.
(map! :n "U" 'evil-redo)

(after! (evil evil-collection)
  ;; Disable echo area messages when changing evil states.
  (setq evil-insert-state-message nil
        evil-replace-state-message nil
        evil-emacs-state-message nil
        evil-visual-line-message nil
        evil-visual-char-message nil
        evil-visual-block-message nil)

  (defun evil-normalize-ctrl-i (&optional frame)
    "Untangle TAB from C-i, so we can indent."
    (define-key input-decode-map [(control ?i)] [control-i])
    (define-key input-decode-map [(control ?I)] [(shift control-i)])
    (map! :map evil-motion-state-map "C-i" nil)
    (define-key evil-motion-state-map [control-i] 'evil-jump-forward))

  (add-hook 'doom-first-buffer-hook #'evil-normalize-ctrl-i)
  ;; Prevent accidental commands when exploring little-used modes.
  (evil-normalize-ctrl-i)

  ;; Prevent accidental commands when exploring little-used modes.
  (map! :m doom-localleader-key nil)

  ;; Indent current line after more evil commands.
  ;; (advice-add 'evil-join :after #'indent-according-to-mode)
  (map! :n "<RET>" 'newline-and-indent)
  (map! "C-j" 'newline-and-indent)

  ;; Extra bindings for compilation and editing commit messages.
  (map! :map (compilation-mode-map with-editor-mode-map message-mode-map)
        ;; Stands for "go run", finishes the current operation.
        :nv "gr" (general-simulate-key "C-c C-c")
        :nv "C-<RET>" (general-simulate-key "C-c C-c")
        ;; Stands for "go quit"
        :nm "gq" (general-simulate-key "C-c C-k"))

  (defun +evil-paste-at-point ()
    (interactive)
    (evil-paste-from-register ?0))

  ;; We want the same save binding everywhere!
  (map! :gi "C-s" (general-key "C-x C-s")
        :gi "<f12>" (general-key "C-x C-s")
        :gi "C-v" '+evil-paste-at-point))

;; Add a few other common bindings since I don't use the commands that live
;; under these keys anyway.
(map! "C-a" 'mark-whole-buffer)

(after! org
  (map! :map org-mode-map
        :nv "gr" (general-simulate-key "C-c C-c")))

;; Make spell-fu compatible with tree-sitter.
(after! (spell-fu tree-sitter)
  (setq-default spell-fu-faces-include
                '(tree-sitter-hl-face:comment
                  tree-sitter-hl-face:doc
                  tree-sitter-hl-face:string
                  font-lock-comment-face
                  font-lock-doc-face
                  font-lock-string-face)))

(after! spell-fu
  (setq-default spell-fu-word-delimit-camel-case t)
  (setq-default spell-fu-faces-exclude
                '(font-lock-constant-face
                  markdown-code-face)))

(map! :after git-timemachine
      :map git-timemachine-mode-map
      "[r" 'git-timemachine-show-previous-revision
      "]r" 'git-timemachine-show-next-revision)

(after! (evil evil-collection)
  ;; (add-hook 'evil-insert-state-exit-hook 'company-abort)
  ;; Associate TAB with all workspace bindings, instead of brackets + w.
  (map! :n "[ TAB" '+workspace/switch-left
        :n "] TAB" '+workspace/switch-right)

  ;; I never use this and it causes weird issues with Wayland + Slack.
  (map! "<Scroll_Lock>" 'ignore)

  (map! "M-[" #'+workspace/switch-left
        "M-]" #'+workspace/switch-right)
  (map! :leader "tp" #'prettify-symbols-mode)

  (map! :map compilation-mode-map
        :n "gr" #'recompile)
  (map! :leader "os" 'eshell)
  (map! :nv "zw" 'count-words
        :n "zG" '+spell/remove-word))

(use-package org-ref
  :after org
  ;; :after-call org-mode
  :config
  ;;(setq org-ref-completion-library 'org-ref-ivy-cite)
  (map! :map org-mode-map
        :localleader
        :n "ri" 'org-ref-insert-ref-link))

(use-package! graphql-mode :mode "\\.gql\\'")

;; Focus project tree with "op" instead of toggling.
(after! treemacs
  (setq treemacs-is-never-other-window t)
  (defun +treemacs/focus ()
    "Initialize or focus treemacs.

Ensures that only the current project is present and all other projects have
been removed.

Use `treemacs-select-window' command for old functionality."
    (interactive)
    (if (doom-project-p)
        (treemacs-add-and-display-current-project)
      (treemacs-select-window)))
  (map! :leader "op" '+treemacs/focus))

;; Provide syntax highlighting to magit diffs.
;; (use-package! magit-delta
;;   :hook (magit-mode . magit-delta-mode)
;;   :config
;;   ;; FIXME Propagate the emacs theme to delta.
;;   (setq magit-delta-default-dark-theme "ansi-dark"))

;; Spell check options
(after! ispell
  (setq ispell-dictionary "en"
        ispell-personal-dictionary "~/.aspell.en.pws"))

;; (use-package! polymode
;;   :disabled
;;   :defer t
;;   :defer-incrementally (polymode-core polymode-classes polymode-methods polymode-base polymode-export polymode-weave))
;; (use-package! poly-markdown
;;   :disabled
;;   :mode (("\\.md\\'" . poly-markdown-mode)))
;; (use-package! poly-org
;;   :disabled
;;   :mode (("\\.org\\'" . poly-org-mode)))
;; TODO Limit docs shown for current function to the type signature (one line), only showing the rest upon using K.
;; TODO Rebind C-c C-c in with-editor-mode (magit commit messages) to "gr" or similar

(after! (company company-box)
  (setq ;; company-auto-commit 'company-explicit-action-p
   ;; Icons make completion quite sluggish!
   company-box-enable-icon nil
   company-idle-delay 0.5)
  ;; (when (featurep 'exwm)
  ;;   (appendq! company-box-doc-frame-parameters '((parent-frame . nil))))
  ;; TODO Fix this so we can indent instead of completing all the time!
  (map! :map company-active-map
        ;; "<tab>" 'company-complete-selection
        ;; "TAB" 'company-complete-selection
        "RET" nil
        [return] nil))

(use-package! evil-owl
  :hook (doom-first-file . evil-owl-mode)
  :config
  (setq evil-owl-display-method 'posframe
        evil-owl-extra-posframe-args `(:internal-border-width ,+snead/frame-border-width
                                       :left-fringe ,+snead/frame-fringe
                                       :right-fringe ,+snead/frame-fringe)
        evil-owl-idle-delay 0.5))

;;(use-package! cherokee-input)

(after! message
  (setq message-cite-style message-cite-style-thunderbird
        message-cite-function 'message-cite-original))

;; Gmail Compatibility, modified from core DOOM emacs.
(after! mu4e
  ;; don't save message to Sent Messages, Gmail/IMAP takes care of this
  (setq mu4e-sent-messages-behavior 'delete)

  (defvar +mu4e-context-gmail nil
    "Whether the current mu4e context is associated with a GMail-like server.")

  ;; In my workflow, emails won't be moved at all. Only their flags/labels are
  ;; changed. Se we redefine the trash and refile marks not to do any moving.
  ;; However, the real magic happens in `+mu4e|gmail-fix-flags'.
  ;;
  ;; Gmail will handle the rest.
  (defun +mu4e--mark-seen (docid _msg target)
    (mu4e--server-move docid (mu4e--mark-check-target target) "+S-u-N"))

  ;; (delq! 'delete mu4e-marks #'assq)
  (setf (alist-get 'trash mu4e-marks)
        (list :char '("d" . "▼")
              :prompt "dtrash"
              :dyn-target (lambda (_target msg) (mu4e-get-trash-folder msg))
              :action
              (lambda (docid msg target)
                (with-mu4e-context-vars (mu4e-context-determine msg nil)
                                        (if +mu4e-context-gmail
                                            (+mu4e--mark-seen docid msg target)
                                          (mu4e--server-move docid (mu4e--mark-check-target target) "-N-u")))))

        ;; Refile will be my "archive" function.
        (alist-get 'refile mu4e-marks)
        (list :char '("r" . "▼")
              :prompt "rrefile"
              :dyn-target (lambda (_target msg) (mu4e-get-refile-folder msg))
              :action
              (lambda (docid msg target)
                (with-mu4e-context-vars (mu4e-context-determine msg nil)
                                        (if +mu4e-context-gmail
                                            (+mu4e--mark-seen docid msg target)
                                          (mu4e--server-move docid (mu4e--mark-check-target target) "-N-u"))))))

  (defun +mu4e-gmail-fix-flags-h (mark msg)
    "This hook correctly modifies gmail flags on emails when they are marked.
Without it, refiling (archiving), trashing, and flagging (starring) email
won't properly result in the corresponding gmail action, since the marks
are ineffectual otherwise."
    (with-mu4e-context-vars (mu4e-context-determine msg nil)
                            (when +mu4e-context-gmail
                              (pcase mark
                                (`trash  (mu4e-action-retag-message msg "-\\Inbox,+\\Trash,-\\Draft"))
                                (`refile (mu4e-action-retag-message msg "-\\Inbox"))
                                (`flag   (mu4e-action-retag-message msg "+\\Starred"))
                                (`unflag (mu4e-action-retag-message msg "-\\Starred"))))))

  (add-hook 'mu4e-mark-execute-pre-hook #'+mu4e-gmail-fix-flags-h))

;; (use-package! org-mu4e
;;   :after mu4e)

(after! mu4e
  (map! :map (mu4e-headers-mode-map mu4e-view-mode-map)
        :ng "C--" nil)
  (setq +mu4e-backend nil
        +mu4e-workspace-name "*email*"
        mu4e-completing-read-function 'completing-read
        mu4e-split-view 'vertical
        mu4e-index-lazy-check t
        mu4e-headers-visible-columns 100
        mu4e-compose-cite-function 'message-cite-original
        ;; mu4e-headers-visible-columns 100
        mu4e-attachment-dir "~/Downloads"
        ;; I can choose to view the whole thread if I want to see related messages.
        mu4e-headers-include-related nil
        ;; Sometimes I have issues with duplicates, so I need to see them.
        mu4e-headers-skip-duplicates nil
        mu4e-headers-leave-behavior 'apply
        ;; mu4e-view-prefer-html t
        ;; mu4e-compose-format-flowed nil
        mu4e-compose-context-policy 'ask
        mu4e-context-policy 'pick-first
        mu4e-index-update-error-warning nil
        ;; I don't use mu4e built-in conversion to html.
        ;; org-mu4e-convert-to-html nil
        ;; Add full citation when replying to emails.
        message-citation-line-function 'message-insert-formatted-citation-line
        ;; These work well if my font has CJK, otherwise Unicode icons may be better.
        ;; mu4e-headers-draft-mark '("D" . "✎")
        ;; mu4e-headers-flagged-mark '("F" . "★")
        ;; mu4e-headers-new-mark '("N" . "!")
        ;; mu4e-headers-seen-mark '("S" . "◎")
        ;; mu4e-headers-unread-mark '("u" . "◉")
        ;; mu4e-headers-replied-mark '("R" . "⤷")
        ;; mu4e-headers-attach-mark '("a" . "🖿")
        mu4e-headers-time-format "%I:%M %p"
        mu4e-headers-fields '((:account-stripe . 1)
                              (:human-date . 10)
                              (:flags . 6)
                              (:from-or-to . 25)
                              (:subject))
        ;; Convert received messages from html to org.
        ;; mu4e-html2text-command "pandoc -f html -t markdown-raw_html-smart-link_attributes+emoji-header_attributes-blank_before_blockquote-simple_tables-inline_code_attributes-escaped_line_breaks+hard_line_breaks --markdown-headings=atx --wrap=auto --columns=80 --lua-filter ~/.config/doom/remove-ids.lua"
        ;; mu4e-view-show-images t
        )
  ;; I really do want evil bindings for viewing emails.
  (remove-hook 'mu4e-view-mode-hook #'evil-emacs-state)
  ;; Disable line highlight when viewing emails.
  (add-hook 'mu4e-view-mode-hook #'doom-disable-hl-line-h)
  (setq-hook! 'mu4e-headers-mode-hook line-spacing 8)
  ;; Execute marks without confirmation.
  (map! :map (mu4e-headers-mode-map mu4e-view-mode-map)
        :n "x" (cmd! (mu4e-mark-execute-all t)))
  ;; Allow me to reload search results.
  (map! :map mu4e-headers-mode-map
        :n "gr" #'mu4e-headers-rerun-search)

  (setq mu4e-view-actions '(("capture message" . mu4e-action-capture-message)
                            ("browser view" . mu4e-action-view-in-browser)
                            ("pdf view" . mu4e-action-view-as-pdf)
                            ("thread view" . mu4e-action-show-thread)))

  (setq sendmail-program "msmtp"
        send-mail-function 'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function 'message-send-mail-with-sendmail)

  ;; Add my email accounts.
  (when nil ;;(file-exists-p "~/.mail/neu")
    (set-email-account!
     "neu"
     `((mu4e-sent-folder . "/neu/Sent")
       (mu4e-drafts-folder . "/neu/Drafts")
       (mu4e-trash-folder . "/neu/Trash")
       (mu4e-refile-folder . "/neu/Archive")
       (mu4e-spam-folder . "/neu/Junk")
       ;; Outlook expects me to move items normally.
       (user-mail-address . "snead.t@northeastern.edu")
       (+mu4e-context-gmail . ,nil)
       (mu4e-sent-messages-behavior . delete)
       ;; Mimic outlook's citation style.
       (message-yank-prefix . "")
       (message-yank-cited-prefix . "")
       (message-yank-empty-prefix . "")
       (message-citation-line-format . "-----------------------\nOn %a, %b %d %Y, %N wrote:\n"))))

  (when (file-exists-p "~/.mail/personal")
    (set-email-account!
     "personal"
     `((mu4e-sent-folder . "/personal/Sent")
       (mu4e-drafts-folder . "/personal/Drafts")
       (mu4e-trash-folder . "/personal/Trash")
       (mu4e-refile-folder . "/personal/Archive")
       (mu4e-spam-folder . "/personal/Junk")
       (user-mail-address . "shelby@snead.xyz")
       (+mu4e-context-gmail . ,nil)
       (message-yank-prefix . "> ")
       (message-yank-cited-prefix . "> ")
       (message-yank-empty-prefix . "> ")
       (mu4e-sent-messages-behavior . sent)
       (message-citation-line-format . "On %a, %b %d, %Y at %R %f wrote:\n"))))

  (when (file-exists-p "~/.mail/gmail")
    (set-email-account!
     "gmail"
     `((mu4e-sent-folder . "/gmail/[Gmail]/Sent Mail")
       (mu4e-drafts-folder . "/gmail/[Gmail]/Drafts")
       (mu4e-trash-folder . "/gmail/[Gmail]/Trash")
       (mu4e-refile-folder . "/gmail/Graveyard")
       (mu4e-spam-folder . "/gmail/[Gmail]/Spam")
       ;; Gmail expects me to change labels rather than move stuff?
       (user-mail-address . "taylorsnead@gmail.com")
       (+mu4e-context-gmail . ,t)
       (mu4e-sent-messages-behavior . delete)
       (message-yank-prefix . "> ")
       (message-yank-cited-prefix . "> ")
       (message-yank-empty-prefix . "> ")
       (message-citation-line-format . "On %a, %b %d, %Y at %R %f wrote:\n"))))

  (defun mu4e-all-contexts-var (sym)
    "A list of all the values of the given symbol in each mu4e context."
    (mapcar (lambda (ctx) (cdr (assoc sym (mu4e-context-vars ctx))))
            mu4e-contexts))

  ;; Build bookmark queries.
  (let* ((all-trash (mu4e-all-contexts-var 'mu4e-trash-folder))
         (all-spam (mu4e-all-contexts-var 'mu4e-spam-folder))
         (all-archive (mu4e-all-contexts-var 'mu4e-refile-folder))

         (all-sent (mu4e-all-contexts-var 'mu4e-sent-folder))
         (all-names (mapcar #'mu4e-context-name mu4e-contexts)))
    (setq my/show-all-trash (mapconcat (lambda (d) (format "maildir:%s" d))
                                       all-trash " or ")
          my/hide-all-trash (concat (mapconcat (lambda (d) (format "not maildir:%s" d))
                                               (append all-trash all-spam) " and ")
                                    " and not flag:trashed")
          my/show-all-inboxes (format "(%s) and not flag:trashed" (mapconcat (lambda (d) (format "maildir:/%s/INBOX" d))
                                                                             all-names " or "))
          my/show-all-archive (concat (mapconcat (lambda (d) (format "maildir:%s" d))
                                                 all-archive " or ")
                                      " and not flag:trashed")
          my/show-all-sent (mapconcat (lambda (d) (format "maildir:%s" d))
                                      all-sent " or ")))
  ;; Add bookmarks for all important mail categories.
  (setq mu4e-bookmarks
        '((:name "Inbox" :query my/show-all-inboxes :key ?i)
          (:name "Unread Messages" :query (format "flag:unread and (%s)" my/hide-all-trash) :key ?u)
          (:name "Today" :query (format "date:today..now and (%s)" my/hide-all-trash) :key ?t)
          (:name "This Week" :query (format "date:7d..now and (%s)" my/hide-all-trash) :hide-unread t :key ?w)
          (:name "Archive" :query my/show-all-archive :key ?a)
          (:name "Sent" :query my/show-all-sent :key ?s)
          (:name "Trash" :query my/show-all-trash :key ?T)))

  ;; Make opening the inbox even faster with one key press.
  (defun +mu4e-open-inbox ()
    (interactive)
    (mu4e-headers-search my/show-all-inboxes))

  (map! :map (mu4e-main-mode-map mu4e-headers-mode-map)
        :n "i" #'+mu4e-open-inbox)

  (map! :map mu4e-main-mode-map
        :n "gr" #'mu4e-update-mail-and-index)

  (defun mu4e-compose-from-mailto (mailto-string)
    (require 'mu4e)
    (unless mu4e~server-props (mu4e t) (sleep-for 0.1))
    (let* ((mailto (rfc2368-parse-mailto-url mailto-string))
           (to (cdr (assoc "To" mailto)))
           (subject (or (cdr (assoc "Subject" mailto)) ""))
           (body (cdr (assoc "Body" mailto)))
           (org-msg-greeting-fmt (if (assoc "Body" mailto)
                                     (replace-regexp-in-string "%" "%%"
                                                               (cdr (assoc "Body" mailto)))
                                   org-msg-greeting-fmt))
           (headers (-filter (lambda (spec) (not (-contains-p '("To" "Subject" "Body") (car spec)))) mailto)))
      (mu4e~compose-mail to subject headers)))
  )

;; (after! (mu4e persp-mode)
;;   (persp-def-auto-persp "*email*"
;;                         :buffer-name "^\\*mu4e"
;;                         :dyn-env '(after-switch-to-buffer-functions ;; prevent recursion
;;                                    (persp-add-buffer-on-find-file nil)
;;                                    persp-add-buffer-on-after-change-major-mode)
;;                         :hooks '(after-switch-to-buffer-functions)
;;                         :switch 'frame)
;;   (persp-def-auto-persp "browse"
;;                         :buffer-name "^\\[Firefox\\]"
;;                         :dyn-env '(after-switch-to-buffer-functions ;; prevent recursion
;;                                    (persp-add-buffer-on-find-file nil)
;;                                    persp-add-buffer-on-after-change-major-mode)
;;                         :hooks '(after-switch-to-buffer-functions)
;;                         :switch 'frame))

;; Write emails in markdown, sent as legit HTML!
(use-package! md-msg
  ;; Enable markdown for all mu4e reading and writing purposes.
  :hook (mu4e-headers-mode . md-msg-mode)
  :config
  (setq mml-content-disposition-alist '((text (rtf . "attachment")
                                         (t . nil))
                                        (t . "attachment")))
  ;; TODO Move this binding to md-msg itself.
  (map! :map md-msg-view-mode-map
        :n "q" 'md-msg-view-quit-buffer)
  (map! :map md-msg-edit-mode-map
        :n "gr" 'message-send-and-exit)
  ;; Make email nicer to read and write.
  (add-hook! '(md-msg-view-mode-hook md-msg-edit-mode-hook mu4e-view-mode-hook) #'olivetti-mode))

(after! alert
  (setq alert-default-style 'libnotify))

;; Notify me when compilations finish!
(defun +alert/compilation (buffer status)
  (alert (s-capitalize status)
         :title (buffer-name buffer)))
(add-hook 'compilation-finish-functions #'+alert/compilation)

(after! web-mode
  (add-to-list 'web-mode-engines-alist '("django" . "\\.tera\\.(xml|html)\\'")))

(defun disable-line-numbers ()
  (interactive)
  (display-line-numbers-mode -1))

(add-hook! '(pdf-outline-buffer-mode-hook)
           #'disable-line-numbers)

(use-package! olivetti
  :hook ((org-mode markdown-mode magit-status-mode forge-topic-mode gnus-article-mode-hook) . olivetti-mode)
  :bind (:map doom-leader-map
              ("tz" . olivetti-mode))
  :config
  (add-hook! '(olivetti-mode-hook org-mode-hook markdown-mode-hook) #'disable-line-numbers)
  (setq-default olivetti-body-width 100))

(setq-default ;;x-underline-at-descent-line t
 underline-minimum-offset 2)

;; Retain zen style in sub-buffers. Essential for markdown content with embedded
;; code blocks!
(after! polymode
  (add-to-list 'polymode-move-these-minor-modes-from-base-buffer 'olivetti-mode)
  (add-hook 'polymode-init-inner-hook
            (lambda ()
              (let* ((fix-pitch (face-attribute 'fixed-pitch :family))
                     (fix-font (face-attribute 'fixed-pitch :font))
                     (fix-height (face-attribute 'fixed-pitch :height))
                     (bg (face-attribute 'markdown-code-face :background))
                     (props `(:inherit markdown-code-face
                              :extend t
                              :height ,fix-height
                              :family ,fix-pitch
                              :font ,fix-font)))
                (oset pm/chunkmode adjust-face props)))))

(setq +ligatures-extra-symbols
      '(:name "»"
        :src_block "»"
        :src_block_end "«"
        :quote "“"
        :quote_end "”"
        :lambda "λ"
        :def "ƒ"
        :composition "∘"
        :map "↦"
        :null "∅"
        ;; :not "¬"
        ;; :in "∈"
        ;; :not-in "∉"
        ;; :and "∧"
        ;; :or "∨"
        ;; :for "∀"
        ;; :some "∃"
        :return "↑"
        :yield "∃"
        :union "⋃"
        :intersect "∩"
        :dot "•"
        ;; Org-specific symbols
        :title "#"
        :subtitle "##"
        :begin_quote   "❮"
        :end_quote     "❯"
        :begin_export  "⯮"
        :end_export    "⯬"
        :section    "§"
        :end           "∎"
        :exclamation "!"
        :dash "-"
        :endash "--"
        :asterisk "*"
        :lt "<"
        :nothing ""
        :at_symbol "@"
        :pound "#"
        :pipe "|"
        :turnstile "|—"
        :arrow "->"
        :vertical "│"
        :merge-right "├╮"
        :split-right "├╯"))

;; (after! org
;;   (set-ligatures! 'org-mode
;;     :title "#+TITLE:"
;;     :title "#+title:"
;;     :quote "#+BEGIN_QUOTE"
;;     :quote_end "#+END_QUOTE"
;;     :quote "#+begin_quote"
;;     :quote_end "#+end_quote"
;;     :begin_export "#+BEGIN_EXPORT"
;;     :end_export "#+END_EXPORT"
;;     :begin_export "#+begin_export"
;;     :end_export "#+end_export"
;;     :begin_quote "#+BEGIN_VERSE"
;;     :end_quote "#+END_VERSE"
;;     :begin_quote "#+begin_verse"
;;     :end_quote "#+end_verse"
;;     :section ":PROPERTIES:"
;;     :end ":END:"))

(after! markdown-mode
  (set-ligatures! 'markdown-mode
    :src_block "```")
  (setq! markdown-header-scaling t
         markdown-enable-wiki-links t)
  (add-hook! 'markdown-mode-hook #'variable-pitch-mode)

  ;; (add-hook! 'markdown-mode-hook #'prettify-symbols-mode)
  ;; (setq-hook! 'markdown-mode-hook
  ;;   prettify-symbols-alist
  ;;   `(("# " . ,9673)
  ;;     ("## " . ,9675)
  ;;     ("### " . ,10040)
  ;;     ("#### " . ,10047)))
  )

(use-package! obsidian
  :after markdown-mode
  :config
  (setq! obsidian-directory "~/documents/notes/Personal"
         obsidian-inbox-directory nil)
  (global-obsidian-mode t)
  (obsidian-backlinks-mode t)
  (map! :map obsidian-mode-map
        :n "gd" #'obsidian-follow-link-at-point
        :n "gj" #'obsidian-jump
        :n "gb" #'obsidian-backlink-jump
        :n "gt" #'obsidian-find-tag
        :n "gT" #'obsidian-insert-tag))


;; (after! web-mode
;;   (setq web-mode-prettify-symbols-alist nil))


;; Prettify escaped symbols in viewed emails as much as possible.
;; This doesn't affect when writing/responding to emails.
;; TODO maybe there's a better machanism for replacing these that works more consistently?
(after! md-msg
  (set-ligatures! 'md-msg-view-mode
    :exclamation "\\!"
    :dash "\\-"
    :endash "\\--"
    :asterisk "\\*"
    :lt "\\<"
    ;; :nothing "\n\\\n"
    ;; :nothing "\n\n\n"
    ;; :nothing "\\"
    :at_symbol "\\@"
    :pound "\\#"
    :arrow "-\\>"
    :pipe "\\|"
    :turnstile "\\|-"))

;;;; Periodically clean buffers
(use-package! midnight
  :hook (doom-first-buffer . midnight-mode)
  :config
  (setq clean-buffer-list-kill-regexps '("\\`\\*Man "
                                         "\\`\\*helpful "
                                         "\\`\\*Calc"
                                         "\\`\\*xref"
                                         "\\`\\*lsp"
                                         "\\`\\*company"
                                         "\\`\\*straight-process\\*"
                                         "\\`\\*Flycheck"
                                         "\\`\\*forge"
                                         "\\`*ivy-occur"
                                         "magit"
                                         "\\`vterm"
                                         "\\`\\*eshell"
                                         "Aweshell:")
        clean-buffer-list-delay-general 2
        clean-buffer-list-delay-special (* 60 60 2)
        ;; Clean out potentially old buffers every 12 hours
        ;; I think this causes Emacs to hang when it runs
        midnight-period (* 60 60 12)))

;; Using C-/ for comments aligns with other editors.
;; IMPORTANT: This MUST be in the global map or else undo-tree doesn't work!
(map! :map global-map
      "C-/" 'comment-dwim)
(map! :i "C-z" 'undo)

(after! ox-latex
  (add-to-list 'org-latex-minted-langs '(rust "rust"))
  (setq org-latex-listings 'minted)
  (add-to-list 'org-latex-default-packages-alist '("" "minted" nil)))

(eval-after-load 'ox '(require 'ox-koma-letter))
(eval-after-load 'ox '(require 'ox-beamer))
(eval-after-load 'ox-koma-letter
  '(progn
     (add-to-list 'org-latex-classes
                  '("my-letter"
                    "\\documentclass\{scrlttr2\}
     \\usepackage[english]{babel}
     \[DEFAULT-PACKAGES]
     \[PACKAGES]
     \[EXTRA]"))

     (setq org-koma-letter-default-class "my-letter")))

(use-package! ox-moderncv
  :commands (org-cv-export-to-pdf)
  :config
  (defun org-cv-export-to-pdf ()
    (interactive)
    (let* ((org-latex-default-packages-alist nil)
           (org-latex-packages-alist nil)
           (org-latex-with-hyperref nil)
           (outfile (org-export-output-file-name ".tex" nil)))
      (org-export-to-file 'moderncv outfile
        nil nil nil nil nil
        (lambda (f) (org-latex-compile f))))))

;; TODO Disable lsp-ui to fix loss of window config in exwm!

;; The default popup is SLOW, use posframe or minibuffer.
;; TODO We need chinese font with same height as my font.
(after! pyim
  (setq pyim-page-tooltip 'posframe))

(use-package! string-inflection)

;; Shows habits on a consistency graph.
(use-package! org-habit :disabled :after org)

;; Notify me when a deadline is fast approaching.
(use-package! org-notify
  :disabled
  :config
  (org-notify-add 'default
                  ;; If we're more than an hour past the deadline, don't notify at all.
                  '(:time "-1h"
                    :actions ())
                  ;; A couple hours before a deadline, start sending system notifications every 20 minutes.
                  '(:time "2h"
                    :period "20m"
                    :duration 10
                    :actions -notify))
  (org-notify-start))

;; FIXME evil bindings don't work and workspaces mess this up.
(use-package! pdf-continuous-scroll-mode
  ;; :hook (pdf-view-mode . pdf-continuous-scroll-mode)
  :disabled
  :config
  (map! :map 'pdf-continuous-scroll-mode-map
        :n "j" #'pdf-continuous-scroll-forward
        :n "k" #'pdf-continuous-scroll-backward
        :n "C-j" #'pdf-continuous-next-page
        :n "C-k" #'pdf-continuous-previous-page
        :n "G" #'pdf-cscroll-last-page
        :n "g g" #'pdf-cscroll-first-page
        :n "<mouse-4>" #'pdf-continuous-scroll-forward
        :n "<mouse-5>" #'pdf-continuous-scroll-backward))

(use-package! dired-show-readme
  :disabled
  :hook (dired-mode . dired-show-readme-mode))

(after! evil
  (defun playerctl-play-pause ()
    (interactive)
    (shell-command "playerctl play-pause"))
  (defun playerctl-next ()
    (interactive)
    (shell-command "playerctl next"))
  (defun playerctl-previous ()
    (interactive)
    (shell-command "playerctl previous"))
  (map! :leader
        "o g" #'=calendar
        "w U" #'winner-redo
        "w D" #'delete-other-windows
        ;; "<f19>" (general-key (format "%s %s" doom-leader-key doom-leader-key))
        "TAB" #'+workspace/switch-to
        "\\" #'set-input-method
        "=" #'toggle-input-method
        "w s" (cmd! (evil-window-vsplit) (other-window 1))
        "w v" (cmd! (evil-window-split) (other-window 1))
        :desc "media" "m" nil
        "m c" #'playerctl-play-pause
        "m n" #'playerctl-next
        "m p" #'playerctl-previous
        "m s" #'+wm/screenshot
        "m S" #'desktop-environment-screenshot-part
        "DEL" #'+workspace/delete))

;; Show window hints big and above X windows.
;; Load this early to give windows their header-line hints ASAP.
(use-package! ace-window
  :init
  (map! :leader "j" #'ace-window)
  :config
  ;; Show the window key in the header line.
  (ace-window-display-mode))

;; Allow easy NPM commands in most programming buffers.
(use-package! npm-mode
  :hook ((prog-mode text-mode conf-mode) . npm-mode))

;; LSP formatting doesn't work well for JSX/TSX, so disable it.
;; (setq-hook! '(typescript-mode-hook typescript-tsx-mode-hook js-mode-hook js-jsx-mode-hook) +format-with-lsp nil)
(after! eglot
  (add-to-list 'eglot-server-programs
               '((typescript-tsx-mode :language-id "typescriptreact") . ("typescript-language-server" "--stdio"))))

(appendq! +format-on-save-disabled-modes
          '(web-mode
            mhtml-mode
            mu4e-compose-mode
            md-msg-edit-mode
            message-mode))

(after! apheleia
  (add-to-list 'apheleia-mode-alist '(markdown-mode . prettier-markdown)))

(after! vterm
  (setq vterm-buffer-name-string "vterm %s"))

(map! :mnv "go" #'avy-goto-char-2)

(defun calc-buffer-predicate (b)
  (member b calc-buffer-list))
(after! calc
  (add-hook 'calc-trail-mode-hook 'hide-mode-line-mode)
  (add-hook 'calc-mode-hook 'hide-mode-line-mode))
(defun make-calc-frame ()
  (interactive)
  (let ((frame (make-frame '((buffer-predicate . calc-buffer-predicate)))))
    (select-frame frame)
    (calc nil t)))

;; Launch programs directly from an Emacs prompt.
(use-package! app-launcher
  :bind (:map doom-leader-map
              ("o o" . app-launcher-run-app)))

;; Sync my org agenda entries to my calendar, so I can see these entries on my
;; phone and get reminders there.
(use-package! org-caldav
  :disabled
  :config
  (setq org-caldav-url "https://dav.mailbox.org/caldav"
        org-caldav-calendar-id "Y2FsOi8vMC8zMQ"
        org-caldav-inbox "~/org/inbox.org"
        org-caldav-files '("~/org/me.org" "~/org/todo.org" "~/org/spring-2021.org" "~/org/dailp.org")
        org-caldav-delete-calendar-entries 'always
        org-caldav-sync-direction 'twoway
        org-caldav-resume-aborted 'never
        ;; org-icalendar-include-todo 'unblocked
        ;; TODOs don't work with org-caldav yet, so just make events for the deadline.
        org-icalendar-use-deadline '(event-if-not-todo event-if-todo-not-done)
        org-icalendar-timezone "UTC"
        ;; Alert me 20 minutes before events on my phone.
        org-icalendar-alarm-time 20)

  ;; Don't interrupt me when syncing calendars!
  (defun +org-caldav-sync-quiet ()
    "Sync calendars without showing the results."
    (let ((org-caldav-show-sync-results nil))
      (org-caldav-sync)))

  ;; Sync my calendars every hour or so.
  ;;(run-with-timer 5 3600 #'+org-caldav-sync-quiet)
  )

(after! org
  (setq org-timer-countdown-timer-title "Timer finished"))

;; Give full state names to make learning the names easier.
(after! evil
  ;; (setq-default evil-move-cursor-back t)
  (setq evil-normal-state-tag " NORMAL "
        evil-insert-state-tag " INSERT "
        evil-visual-state-tag " VISUAL "
        evil-visual-line-tag " VLINE "
        evil-visual-block-tag " VBLOCK "
        evil-emacs-state-tag " EMACS "
        evil-operator-state-tag " OPERATOR "
        evil-replace-state-tag " REPLACE "))

(after! doom-modeline
  (setq doom-modeline-buffer-file-name-style 'relative-to-project
        doom-modeline-persp-name t
        doom-modeline-icon nil
        doom-modeline-buffer-state-icon nil
        doom-modeline-modal-icon nil
        doom-modeline-height 26
        doom-modeline-bar-width +snead/frame-border-width)
  (doom-modeline-def-segment exwm-title '(:eval (or exwm-title (doom-modeline-segment--buffer-info-simple))))
  (doom-modeline-def-segment major-mode 'mode-name)
  (doom-modeline-def-segment buffer-position '(" " mode-line-percent-position))
  (doom-modeline-def-segment ace-window '(:eval (and (featurep 'ace-window)
                                                     (propertize (concat " " (upcase (window-parameter (selected-window) 'ace-window-path)) " ")
                                                                 'face
                                                                 (if (doom-modeline--active)
                                                                     'doom-modeline-bar
                                                                   'doom-modeline-bar-inactive)))))
  (doom-modeline-def-segment ranger '(:eval (ranger-header-line)))
  (doom-modeline-def-segment buffer-info-revised
    "Combined information about the current buffer, including the current working
directory, the file name, and its state (modified, read-only or non-existent)."
    (concat
     (doom-modeline--buffer-mode-icon)
     (doom-modeline--buffer-state-icon)
     (doom-modeline--buffer-name)))

  (doom-modeline-def-segment vertical-pad (list (propertize " " 'display '(raise +0.25))
                                                (propertize " " 'display '(raise -0.25))))

  (doom-modeline-def-modeline 'main
    '(ace-window modals buffer-info-revised buffer-position " " matches vertical-pad)
    '(misc-info input-method major-mode vcs lsp " "))
  (doom-modeline-def-modeline 'project
    '(ace-window buffer-default-directory vertical-pad)
    '(misc-info irc mu4e github debug major-mode process " "))
  (doom-modeline-def-modeline 'vcs
    '(ace-window buffer-info-simple vertical-pad)
    '(misc-info vcs " "))
  (doom-modeline-def-modeline 'simple
    '(ace-window "  " exwm-title vertical-pad)
    '(misc-info major-mode " "))
  (doom-modeline-def-modeline 'pdf
    '(ace-window " " matches buffer-info-simple pdf-pages vertical-pad)
    '(misc-info major-mode process vcs " "))
  (doom-modeline-def-modeline 'dashboard
    '(ace-window window-number buffer-default-directory-simple vertical-pad)
    '(misc-info irc mu4e github debug minor-modes input-method major-mode process " "))
  (doom-modeline-def-modeline 'ranger
    '(ace-window " " ranger vertical-pad)
    '())
  (add-hook 'ranger-mode-hook
            (defun doom-modeline-set-ranger-modeline ()
              (setq-local mode-line-format nil
                          header-line-format (doom-modeline 'ranger))))

  (defun doom-modeline-set-header ()
    (unless (eq mode-line-format nil)
      (setq-local header-line-format mode-line-format
                  mode-line-format nil)))
  ;; (add-hook! 'text-mode-hook #'doom-modeline-set-header)
  ;; (doom-modeline-set-modeline 'upper t)
  ;; Add a mini-modeline with: git, workspace, time, battery, exwm tray

  )

(after! evil-escape
  (setq evil-escape-delay 0.04))

(defvar +snead/volume nil)
;;(defun +snead/volume-update ()
;;(setq +snead/volume (list (+svg-icon-string "material" "volume-high")
;;(propertize " " 'display '(space :width 0.5))
;;(concat (desktop-environment-volume-get) "%"))))
;;(after! desktop-environment
;;(run-with-timer 1 2 #'+snead/volume-update))

(use-package! mini-modeline
  :if (equal "t" (getenv "EMACS_EXWM"))
  :after doom-modeline
  :hook (doom-modeline-mode . mini-modeline-mode)
  :config
  ;; Avoid putting time in global-mode-string, instead explicitly showing time.
  ;; (doom-modeline-def-segment time 'display-time-string)
  ;; (doom-modeline-def-segment wifi )
  ;; Make a custom doom-modeline to sit in the echo area.
  ;; (doom-modeline-def-modeline 'lower
  ;;   '()
  ;;   '(mu4e persp-name battery " " time))

  (defvar +snead/wifi-name nil)
  (defun +snead/wifi-update ()
    (let* ((network-name (string-trim (shell-command-to-string "iwctl station wlan0 show | rg Connected | cut -d' ' -f17-")))
           (connected (not (string-empty-p network-name))))
      (setq +snead/wifi-name
            (propertize "--"
                        'display (svg-icon "material" (if connected "wifi" "wifi-off") "white")
                        'help-echo (if connected network-name "Disconnected")))))
  ;;(run-with-timer 1 5 #'+snead/wifi-update)

  (let ((half-space (propertize " " 'display '(space :width 0.5))))
    (setq mini-modeline-r-format `(
                                   (:eval (doom-modeline-segment--mu4e))
                                   ;;(:eval (+svg-icon-string "material" "folder"))
                                   ,half-space
                                   (:eval (+workspace-current-name))
                                   "  "
                                   (:eval +snead/wifi-name)
                                   "  "
                                   (:eval +snead/volume)
                                   "  "
                                   (:eval (let ((status doom-modeline--battery-status))
                                            (list (car status) (cdr status))))
                                   "  "
                                   ;;(:eval (+svg-icon-string "material" "clock-outline"))
                                   ,half-space
                                   display-time-string)
          ;; Make room for an external system tray on the right side.
          mini-modeline-right-padding 10
          ;; Don't apply extra faces.
          mini-modeline-enhance-visual nil
          mini-modeline-update-interval 0.5)
    )
  ;; Show battery life and current time in the mini-modeline.
  (display-battery-mode)
  (display-time-mode)
  ;; Remove time from misc-info, so that can go into the header.
  ;; Then, the time segment uses display-time-string directly.
  (setq-default global-mode-string (remq 'display-time-string global-mode-string))
  ;; Remove load from the time string, it was adding too much.
  (setq display-time-string-forms (remove 'load display-time-string-forms))
  ;; Specialized header lines instead of mode lines.
  (defun doom-modeline-set-modeline (key &optional default)
    "Set the modeline format. Does nothing if the modeline KEY doesn't exist.
If DEFAULT is non-nil, set the default mode-line for all buffers.

Redefined to change the header-line instead of the mode-line.
If there's a local header-line-format, don't step on its feet!
Move it to the mode-line."
    (when-let ((modeline (doom-modeline key)))
      (if default
          (setf (default-value 'mode-line-format) (list "%e" modeline))
        (progn
          (when (and (local-variable-p 'header-line-format) (not (equal "%e" (car header-line-format))))
            (setq-local mode-line-format header-line-format))
          (setq-local header-line-format (list "%e" modeline))))
      ))

  (defun doom-modeline-unfocus ()
    "Unfocus mode-line."
    (setq doom-modeline-remap-face-cookie
          (face-remap-add-relative 'header-line 'mode-line-inactive))))

;; Add extra line spacing for some modes.
;; Not in programming modes because indent guides look a bit funny spaced out.
(setq-hook! '(olivetti-mode-hook
              mu4e-headers-mode-hook)
  line-spacing 4)

(map! :leader "fa" (cmd! (consult-find "~")))

(map! :leader "oe" #'proced)
(after! proced
  (map! :map proced-mode-map
        :n "gr" #'proced-update))

;; (after! which-key
;;   (setq which-key-idle-delay 0.4
;;         which-key-show-prefix nil))

;; Make which-key prettier with groups and command descriptions.
(use-package! pretty-which-key
  :disabled
  :after which-key
  :config
  ;; Add groups and command descriptions to several modes.
  (require 'pretty-which-key-modes))

(defun +which-key-show-evil-major (&optional all mode)
  (interactive "P")
  (if (which-key--popup-showing-p)
      ;; Hide the existing popup.
      (progn ;; (setq-local which-key-persistent-popup nil)
        (which-key--hide-popup))
    ;; Show the popup!
    (let* ((map-sym (intern (format "%s-map" (or mode major-mode))))
           (value (and (boundp map-sym) (symbol-value map-sym)))
           (evil-value (or (evil-get-auxiliary-keymap value evil-state)
                           (evil-get-auxiliary-keymap value 'normal)
                           value)))
      (if (and value (keymapp value))
          (progn (which-key--show-keymap
                  "Major-mode bindings"
                  evil-value
                  (apply-partially #'which-key--map-binding-p evil-value)
                  all
                  t)
                 ;; (setq-local which-key-persistent-popup t)
                 )
        (message "which-key: No map named %s" map-sym)))))

;; Show help menus in evil-bound modes.
(map! :after mu4e
      :map mu4e-headers-mode-map
      :mn "?" #'+which-key-show-evil-major)

(after! pdf-view
  (map! :map pdf-view-mode-map
        :mn "?" #'+which-key-show-evil-major))

;; Center the minibuffer to make it easier to read quickly.
(defvar +snead/minibuffer-margin 120)
(defun +snead/center-minibuffer ()
  (let ((margin +snead/minibuffer-margin))
    (unless (and (featurep 'mini-frame) mini-frame-mode)
      (set-window-fringes nil margin margin))))
;; (add-hook 'minibuffer-setup-hook #'+snead/center-minibuffer)

(map! :after envrc
      :leader "e" envrc-command-map)

;; Benchmark startup if Emacs is launched with --debug-init
(use-package! benchmark-init
  :disabled
  ;; :if doom-debug-mode
  :config
  (add-hook 'doom-first-input-hook #'benchmark-init/deactivate))

(custom-set-faces!
  '(doom-modeline-spc-face :inherit nil)
  '(header-line :inherit mode-line))

(use-package! eldoc-box
  :disabled
  ;; :hook ((prog-mode) . eldoc-box-hover-mode)
  :config
  ;; TODO Avoid point when calculating the box position. (Useful for small windows)
  (defun +eldoc-box--upper-corner-position-function (width _)
    "Place the box at the upper-right corner of the selected window,
rather than the default which places it relative to the whole frame.
Position is calculated base on WIDTH and HEIGHT of childframe text window"
    (cons (+ (window-pixel-left) (- (window-pixel-width) width 8))
          ;; y position + a little padding (16)
          (+ (window-pixel-top) (window-header-line-height))))
  (setq eldoc-box-position-function #'+eldoc-box--upper-corner-position-function)
  ;; Remove the header-line in the eldoc-box.

  (after! mini-modeline
    (add-hook 'eldoc-box-buffer-hook 'mini-modeline--no-header)))

(after! ws-butler
  (setq ws-butler-keep-whitespace-before-point t))

;; (setq-default inferior-lisp-program "common-lisp.sh")

(setq lsp-sqls-connections
      '(((driver . "postgresql") (dataSourceName . "host=127.0.0.1 port=5432 database=customers sslmode=disable"))
        ((driver . "postgresql") (dataSourceName . "host=127.0.0.1 port=5432 user=postgres database=dev_database_lvus sslmode=disable"))))
(setq sql-connection-alist
      '((pool-a
         (sql-product 'postgres)
         (sql-server "localhost")
         ;; (sql-user "me")
         ;; (sql-password "mypassword")
         (sql-database "customers")
         (sql-port 5432))))

;; Format .sql files using sqlfluff
(set-formatter! 'sqlfluff '("sqlfluff" "format" "--config" (format "%s/.sqlfluff" (projectile-project-root)) "--disable-progress-bar" "-n"  "-") :modes '(sql-mode))

;; Ensure formatting programs installed at the project level are automatically used.
(after! format-all
  (advice-add 'format-all-buffer--with :around #'envrc-propagate-environment))

(use-package! exec-path-from-shell
  :config
  ;; Ensure my GUI prompt is used for SSH auth.
  (defun +snead/fix-ssh-env ()
    (exec-path-from-shell-copy-env "SSH_AGENT_PID")
    (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))
  (add-hook! 'magit-status-mode-hook '+snead/fix-ssh-env))

(use-package! prisma-mode
  :mode (("\\.prisma\\'" . prisma-mode)))

(use-package! tera-mode
  :mode (("\\.tera\\'" . tera-mode)
         ("\\.tera\\.html\\'" . tera-mode)))

(use-package! phscroll)

(after! evil-snipe
  (setq! evil-snipe-scope 'whole-visible))

(use-package! eglot-booster
  :after eglot
  :disabled (eq system-type 'darwin)
  :config (eglot-booster-mode))

(defun snead/chmod-this-file (mode)
  (interactive
   (list (read-file-modes "File modes: ")))
  (unless (and buffer-file-name (file-exists-p buffer-file-name))
    (user-error "Buffer is not visiting any file"))
  (chmod buffer-file-name mode))

(map! :leader
      "fC" 'editorconfig-find-current-editorconfig
      "fc" 'doom/copy-this-file
      "fm" 'snead/chmod-this-file)

;; Enable native smooth scroll! This new "precision" mode actually works without
;; being super duper laggy like the old pixel-scroll-mode.
;; It's slightly laggy with a touchpad but PERFECT with a classic scroll wheel.
(setq! mouse-wheel-scroll-amount '(1 ((shift) . hscroll))
       pixel-scroll-precision-interpolation-factor 1.5)
;; (pixel-scroll-precision-mode)

(after! corfu
  (setq-default corfu-auto-delay 0.15))

(setq! mac-command-modifier 'control)
