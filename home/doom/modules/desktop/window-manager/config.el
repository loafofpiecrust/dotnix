;;; desktop/exwm/config.el -*- lexical-binding: t; -*-

(defun +wm/screenshot ()
  "Take a screenshot."
  (interactive)
  (desktop-environment-screenshot)
  (message "Screenshot saved to %s" desktop-environment-screenshot-directory))

(use-package! exwm
  :if (equal "t" (getenv "EMACS_EXWM"))
  :init
  (setq exwm-input-global-keys `(;; TODO hydra for moving windows.
                                 ;; Split the frame, and follow.
                                 ;; TODO delete buffer too if it's an app.
                                 ;;(,(kbd "C-w") . kill-current-buffer)
                                 ;; I don't want a big message just for muting
                                 ;; the volume. I have a bar to show me if it worked.
                                 (,(kbd "<XF86AudioMute>") . desktop-environment-toggle-mute)
                                 (,(kbd "<XF86AudioRaiseVolume>") . desktop-environment-volume-increment)
                                 (,(kbd "<XF86AudioLowerVolume>") . desktop-environment-volume-decrement)
                                 ;; (,(kbd "<print>") . +wm/screenshot)
                                 ;; App Shortcuts
                                 ;; (,(kbd "M-x") . counsel-M-x)
                                 ))

  ;; Show all buffers on all displays since we have DOOM workspaces.
  (setq exwm-workspace-show-all-buffers t
        exwm-layout-show-all-buffers t)

  ;; Pass all keys directly to windows.
  ;; TODO Leverage exwm line and char modes for evil keybindings.
  (setq exwm-manage-configurations '(;; ((string-match-p "^zoom" exwm-class-name)
                                     ;;  floating nil)
                                     (t tiling-header-line (:eval (doom-modeline-format--simple))
                                        tiling-mode-line nil
                                        floating-mode-line nil)))

  ;; FIXME May not need this given the above.
  (setq exwm-input-prefix-keys (list ?\M-\  ?\M-x (aref (kbd "<Multi_key>") 0) (aref (kbd "s-SPC") 0) (aref (kbd "<f19>") 0)))
  (setq exwm-input-simulation-keys '())

  :config
  (map! :leader
        "w f" #'exwm-floating-toggle-floating)

  ;; Let me copy things from other programs.
  (map! :map exwm-mode-map "C-c" nil)

  ;; Fix exwm buffer switching for DOOM.
  (add-hook 'exwm-mode-hook #'doom-mark-buffer-as-real-h)

  ;; Pass keys directly to windows.
  (add-hook 'exwm-mode-hook #'evil-emacs-state)

  (defun exwm-rename-buffer ()
    "Rename the current buffer to match its corresponding window title."
    (interactive)
    (exwm-workspace-rename-buffer
     (let* ((buf-name (concat ":" exwm-class-name ": " exwm-title)))
       (if (<= (length buf-name) 80) buf-name
         (substring buf-name 0 79)))))

  ;; Update each exwm buffer name to match the window class and title.
  (add-hook! '(exwm-update-class-hook exwm-update-title-hook)
             #'exwm-rename-buffer)

  (defun exwm--update-utf8-title-advice (oldfun id &optional force)
    "Only update the window title when the buffer is visible."
    (when (get-buffer-window (exwm--id->buffer id))
      (funcall oldfun id force)))
  ;; Allow persp-mode to restore window configurations involving exwm buffers by
  ;; only changing names of visible buffers.
  (advice-add #'exwm--update-utf8-title :around #'exwm--update-utf8-title-advice)

  ;; Show the program title of exwm buffers in ibuffer.
  (define-ibuffer-column exwm-class (:name "Class")
    (if (bound-and-true-p exwm-class-name)
        exwm-class-name
      ""))

  ;; Use emacs input methods in any application.
  (use-package! exwm-xim
    :config
    ;; These variables are required for X programs to pick up Emacs IM.
    (setenv "XMODIFIERS" "@im=exwm-xim")
    (setenv "GTK_IM_MODULE" "xim")
    (setenv "QT_IM_MODULE" "xim")
    (setenv "CLUTTER_IM_MODULE" "xim")
    (setenv "QT_QPA_PLATFORM" "xcb")
    (setenv "SDL_VIDEODRIVER" "x11")
    (exwm-xim-enable))

  ;; Automatically handle multiple monitors.
  ;; Each monitor corresponds to an Emacs frame, and each frame can focus on a
  ;; different workspace. Workspaces are always shared between all frames.
  (use-package! exwm-randr
    :disabled
    :config
    ;; Put one Emacs frame on my laptop screen, another on HDMI output.
    (setq exwm-randr-workspace-monitor-plist '(0 "eDP1" 1 "HDMI1"))
    (add-hook 'exwm-randr-screen-change-hook
              (defun +exwm-randr-setup ()
                (exec "xrandr --output HDMI1 --right-of eDP1 --auto")))
    (exwm-randr-enable))

  (exwm-enable))

(use-package! desktop-environment
  :after exwm
  :config
  (setq desktop-environment-brightness-normal-decrement "5%-"
        desktop-environment-brightness-normal-increment "5%+")

  (setq desktop-environment-screenshot-directory "~/Pictures/Screenshots")

  ;; This implementation is much faster than the default, preventing Emacs from
  ;; locking up.
  (defun desktop-environment-volume-set (value)
    "Set volume to VALUE."
    (start-process "amixer" nil "amixer" "set" "Master" value))

  (defun desktop-environment-toggle-mute ()
    (interactive)
    (desktop-environment-volume-set "toggle")))

;; Add outer gaps!
(use-package exwm-outer-gaps
  :after exwm
  :defer 2
  :config
  (setq exwm-outer-gaps-width [12 12 12 12])
  (exwm-outer-gaps-mode 1))
