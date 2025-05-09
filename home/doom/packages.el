;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! benchmark-init)


(package! auto-dark)
(package! ewal)
(package! ewal-doom-themes)
(package! ewal-evil-cursors)
(package! catppuccin-theme)

;;(package! common-header-mode-line :recipe (:local-repo "common-header-mode-line-0.5.6"))

;; Utilities
(package! string-inflection)
;; Show registers before using them!
(package! evil-owl :pin "ed5a98644a9cf321de213b50df6473de9f3a71ed")
(package! olivetti)

(package! eglot-booster :recipe (:host github :repo "jdtsmith/eglot-booster"))

;; Extra languages
;; (package! graphql-mode)
(package! polymode)
(package! poly-markdown)
(package! poly-org)
(package! literate-calc-mode)
(package! exec-path-from-shell)
;; Toggle rendered latex preview when point is over it.
;;(package! org-fragtog :disable t)
;; (package! outshine)
;; Better tool for git merges or any 3-way diff.
;; (package! vdiff :disable t)
;; (package! vdiff-magit :disable t)
;; (package! magit-delta :disable t)
;; Edit markdown comments in an indirect buffer.
;; (package! separedit)

;; Show errors inline so they never overlap with code.
(package! flycheck-inline :pin "0662c314bd819f9b46f8b2b13f0c650445b3a8c5")
;; (package! flycheck-posframe :disable t)
;; (package! flycheck-popup-tip :disable t)

(package! casual)
(package! modus-themes)

;; (package! valign
;;   :disable t
;;   :recipe (:host github :repo "casouri/valign"))

;;; Email
(package! org-msg :disable t)
(package! md-msg
  :recipe (:local-repo "custom" :files ("md-msg.el") :build (:not compile)))
;; Desktop notifications upon receiving new emails.
;; (package! mu4e-alert :pin "91f0657c5b245a9de57aa38391221fb5d141d9bd")
;; (package! mu4e-send-delay
;;   :recipe (:host github :repo "cacology/mu4e-send-delay"))

(package! app-launcher
  :pin "d5015e394b0a666a8c7c4d4bdf786266e773b145"
  :recipe (:host github :repo "SebastienWae/app-launcher"))

;; Manage citations and references with ease in org-mode.
(package! org-ref)
;; Full elisp citation management solution. TBD on quality.
(package! citeproc-org)
;; (package! org-pretty-table)

(package! transmission :disable t)

;; System stuff!
;; (package! anzu :pin "7b8688c84d6032300d0c415182c7c1ad6cb7f819")
;; (package! evil-anzu :pin "d3f6ed4773b48767bd5f4708c7f083336a8a8a86")
;; (package! posframe :built-in 'prefer)
(package! mount-mode
  :disable t
  :recipe (:host github :repo "zellerin/mount-mode"))

;;(package! org-cv
;;:recipe (:host gitlab :repo "loafofpiecrust/org-cv" :branch "explicit-dates"))

;; I don't use fcitx at all.
(package! fcitx :disable t)

;; Solaire slows down scrolling too much, though I like how it looks.
(package! solaire-mode :disable t)

;; (package! zoom :pin "a373e7eed59ad93315e5ae88c816ca70404d2d34")

;; TODO vterm is slightly messed up, I'm not quite sure why.
;; (package! vterm :recipe (:no-native-compile t))
;; (package! treemacs :recipe (:no-native-compile t))
(package! vterm :built-in 'prefer)
;; (package! undo-tree :built-in 'prefer)

(package! highlight-numbers :disable t)

;; (package! emms)

(package! dired-show-readme
  :recipe (:host gitlab :repo "kisaragi-hiu/dired-show-readme"))

(package! pdf-tools :built-in 'prefer)
;; (package! pdf-continuous-scroll-mode
;;   :recipe (:host github :repo "dalanicolai/pdf-continuous-scroll-mode.el"))

(package! oauth2)

(package! calibredb)

(package! ace-window
  :pin "57977baeba15b92c987eb7bf824629a9c746a3c8"
  :recipe (:host github :repo "loafofpiecrust/ace-window" :branch "main"))

(package! org-caldav)

(package! mini-modeline
  :recipe (:local-repo "emacs-mini-modeline" :build (:not compile native-compile)))

;;(package! which-key
;;:recipe (:local-repo "~/pie/emacs-which-key" :build (:not compile native-compile)))

;;(package! svg-icon
;;:recipe (:host github :repo "loafofpiecrust/emacs-svg-icon" :branch "icon-submodules"))

(package! hercules
  :recipe (:host gitlab :repo "jjzmajic/hercules.el"))

(package! gsettings)

;; (package! org-pandoc-import
;;   :recipe (:host github
;;            :repo "tecosaur/org-pandoc-import"
;;            :files ("*.el" "filters" "preprocessors")))

(package! ct
  :recipe (:host github
           :repo "neeasade/ct.el"
           :branch "master"))

(package! mixed-pitch)

(package! disk-usage)

(package! eldoc-box)

(package! sly-asdf)

;; Support for prisma, a database schema language
(package! prisma-mode :recipe (:host github :repo "pimeys/emacs-prisma-mode" :branch "main"))

(package! tera-mode
  :recipe (:host github :repo "svavs/tera-mode"))

(package! phscroll :recipe (:host github :repo "misohena/phscroll"))

(package! obsidian :recipe (:host github :repo "licht1stein/obsidian.el"))

;;(package! daemons)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
                                        ;(package! another-package
                                        ;  :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
                                        ;(package! this-package
                                        ;  :recipe (:host github :repo "username/repo"
                                        ;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
                                        ;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
                                        ;(package! builtin-package :recipe (:nonrecursive t))
                                        ;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
                                        ;(package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
                                        ;(package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
                                        ;(unpin! pinned-package)
;; ...or multiple packages
                                        ;(unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
                                        ;(unpin! t)
