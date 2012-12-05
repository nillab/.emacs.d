;; MobileOrg + Dropbox + org-mode
;; Don't forget to create your ~/Dropbox/MobileOrg folder!
;;
;; Example of GTD task:
;; ** TODO [#A] Buy milk :personal:
;;    DEADLINE: <2011-03-11 Fri>
;; Where:
;;    [#A] => Priority from 'A' to 'D'
;;    :personal: => Tag
;; See also:
;; http://thread.gmane.org/gmane.emacs.orgmode/4832/focus=4854

;; org folder
(setq org-directory "~/Dropbox/org")

;; capture
(setq org-default-notes-file (concat org-directory "/notes.org"))

;; Follow links on enter
(setq org-return-follows-link t)

;; Files for syncing
(setq org-agenda-files
    (list (concat org-directory "/gtd.org") (concat org-directory "/someday.org")  (concat org-directory "/journal.org")))

;; Set to the name of the file where new notes will be stored
(setq org-mobile-inbox-for-pull (concat org-directory "/flagged.org"))

;; Set to <your Dropbox root directory>/MobileOrg.
(setq org-mobile-directory "~/Dropbox/MobileOrg")

;; Custom agenda view
(setq org-mobile-force-id-on-agenda-items nil)

;; Push and pull from MobileOrg on open/close of emacs
(add-hook 'after-init-hook 'org-mobile-pull)
(add-hook 'kill-emacs-hook 'org-mobile-push)

;; Push and pull from MobileOrg when away from computer
(defvar my-org-mobile-sync-timer nil)

(defvar my-org-mobile-sync-secs (* 60 20))

(defun my-org-mobile-sync-pull-and-push ()
  (org-mobile-pull)
  (org-mobile-push)
  (when (fboundp 'sauron-add-event)
    (sauron-add-event 'my 3 "Called org-mobile-pull and org-mobile-push")))

(defun my-org-mobile-sync-start ()
  "Start automated `org-mobile-push'"
  (interactive)
  (setq my-org-mobile-sync-timer
        (run-with-idle-timer my-org-mobile-sync-secs t
                             'my-org-mobile-sync-pull-and-push)))

(defun my-org-mobile-sync-stop ()
  "Stop automated `org-mobile-push'"
  (interactive)
  (cancel-timer my-org-mobile-sync-timer))

(my-org-mobile-sync-start)

;; Set keywords and agenda commands
(setq org-todo-keywords
      '((type "TODO" "NEXT" "WAITING" "DONE")))
(setq org-agenda-custom-commands
    '(("w" todo "WAITING" nil)
      ("n" todo "NEXT" nil)
      ("d" "Agenda + Next Actions" ((agenda) (todo "NEXT"))))
)

;; Use org's tag feature to implement contexts.
(setq org-tag-alist '(("STUDIO" . ?s)
                      ("COMPUTER" . ?c)
                      ("MAIL" . ?m)
                      ("HOME" . ?h)
                      ("FIELD" . ?f)
                      ("READING" . ?r)
                      ("DVD" . ?d)))

;; Use color-coded task types.
(setq org-todo-keyword-faces
      '(("NEXT" . (:foreground "yellow" :background "red" :bold t :weight bold))
        ("TODO" . (:foreground "DarkOrange1" :weight bold))
        ("DONE" . (:foregorund "green" :weight bold))
        ("CANCEL" . (:foreground "blue" :weight bold))))

;; Put the archive in a separate file, because the gtd file will
;; probably already get pretty big just with current tasks.
(setq org-archive-location "%s_archive::")

;; Creates several files:
;;
;;   (concat org-directory "/gtd.org")       Where remembered TODO's are stored.
;;   (concat org-directory "/journal.org")   Timestamped journal entries.
;;   (concat org-directory "/remember.org")  All other notes

;; Use a keybinding of "C-c c" for making quick notes from any buffer.

;; These bits of Remembered information must eventually be reviewed
;; and filed somewhere (perhaps in gtd.org, or in a project-specific
;; org file.) The out-of-sight, out-of-mind rule applies here---if I
;; don't review these auxiliary org-files, I'll probably forget what's
;; in them.

(setq org-reverse-note-order t)  ;; note at beginning of file by default.
(setq org-default-notes-file (concat org-directory "/remember.org"))
(setq remember-annotation-functions '(org-remember-annotation))
(setq remember-handler-functions '(org-remember-handler))
(add-hook 'remember-mode-hook 'org-remember-apply-template)

     (setq org-capture-templates
      '(("t" "todo" entry (file+headline (concat org-directory "/gtd.org") "Tasks")
             "* TODO %?\n  %i\n  %a")
        ("n" "note" entry (file+headline (concat org-directory "/notes.org") "Notes to review")
         "* %^{Title}\n  %i\n  %a")
        ("s" "someday" entry (file+headline (concat org-directory "/someday.org") "Ideas")
         "* %^{Title}\n  %i\n  %a")
        ("j" "journal" entry (file+datetree (concat org-directory "/journal.org"))
         "* %?\nEntered on %U\n  %i\n  %a")))

;; Customizations: *work in progress*. The rest is less related to GTD, and more to my
;; particular setup. They are included here for completeness, and so
;; that new org users can see a complete example org-gtd
;; configuration.

;;
;; CUSTOM AGENDAS
;;
(setq org-agenda-custom-commands
      (quote (("P" "Projects" tags "/!PROJECT" ((org-use-tag-inheritance nil)))
              ("s" "Started Tasks" todo "STARTED" ((org-agenda-todo-ignore-with-date nil)))
              ("w" "Tasks waiting on something" tags "WAITING" ((org-use-tag-inheritance nil)))
              ("r" "Refile New Notes and Tasks" tags "REFILE" ((org-agenda-todo-ignore-with-date nil)))
              ("n" "Notes" tags "NOTES" nil))))

 ; Tags with fast selection keys
(setq org-tag-alist (quote ((:startgroup)
                            ("@Errand" . ?e)
                            ("@Work" . ?w)
                            ("@Home" . ?h)
                            ("@Phone" . ?p)
                            ("@Mind" . ?m)
                            ("@Studio" . ?s)
                            (:endgroup)
                            ("NEXT" . ?N)
                            ("PROJECT" . ?P)
                            ("WAITING" . ?W)
                            ("HOME" . ?H)
                            ("ORG" . ?O)
                            ("PLAY" . ?p)
                            ("R&D" . ?r)
                            ("MIND" . ?m)
                            ("STUDIO" . ?S)
                            ("CANCELLED" . ?C))))

; For tag searches ignore tasks with scheduled and deadline dates
(setq org-agenda-tags-todo-honor-ignore-options t)

; Erase all reminders and rebuilt reminders for today from the agenda
(defun my-org-agenda-to-appt ()
  (interactive)
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

; Rebuild the reminders everytime the agenda is displayed
(add-hook 'org-finalize-agenda-hook 'my-org-agenda-to-appt)

; If we leave Emacs running overnight - reset the appointments one minute after midnight
(run-at-time "24:01" nil 'my-org-agenda-to-appt)

;; save all org files every minute
(run-at-time "00:59" 3600 'org-save-all-org-buffers)

;; hide the initial stars. they're distracting
(setq org-hide-leading-stars t)

(setq org-return-follows-link t)

;;
;; Remove Tasks With Dates From The Global Todo Lists
;;
;; Keep tasks with dates off the global todo lists
(setq org-agenda-todo-ignore-with-date t)

;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)

;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)

;; ask me for a note when I mark something as done
(setq org-log-done 'note)

;; The abbrev list allows me to insert links like
;; [[foo:google]]
;; which will google for "foo"
(setq org-link-abbrev-alist
      '(("google" . "http://www.google.com/search?q=")))

(setf org-tags-column -65)
(setf org-special-ctrl-a/e t)

(setq org-log-done t)
(setq org-deadline-warning-days 14)
(setq org-fontify-emphasized-text t)
(setq org-fontify-done-headline t)
(setq org-agenda-include-all-todo nil)
(setq org-export-html-style "<link rel=stylesheet href=\"../e/freeshell2.css\" type=\"text/css\">")
(setq org-export-with-section-numbers nil)
(setq org-export-with-toc nil)
(setq org-adapt-indentation nil)

;; widen category field a little
(setq org-agenda-prefix-format "  %-17:c%?-12t% s")

;; provide the custom functions
(defun gtd ()
   (interactive)
   (find-file (concat org-directory "/gtd.org")))
(provide 'org-gtd)

(defun reference ()
   (interactive)
   (find-file (concat org-directory "/reference.org")))
(provide 'org-reference)

(defun someday ()
   (interactive)
   (find-file (concat org-directory "/someday.org")))
(provide 'org-someday)