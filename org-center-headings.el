;;; org-center-headings.el --- Keep org-headings centered relative to a window  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Arthur Miller

;; Author: Arthur Miller <arthur.miller@live.com>
;; Keywords: convenience, extensions, outlines, tools
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.1"))
;; URL: https://github.com/amno1/org-hide-leading-stars

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; See readme.org for the discussion.

;;; Code:

(require 'shr)

(defgroup org-center-headings nil
  "Align org-headings on the screen."
  :prefix "org-center-"
  :group 'org)

(defcustom org-center-headings-formatted-only t
  "Center only headings with center formatting"
  :type 'boolean
  :group 'org-center)

(defvar org-leading-stars-re "^[ \t]*\\*+"
  "Regex used to recognize leading stars in org-headings.")

(defcustom org-center-headings-marker-re "^[ \t]*\\*+[ \t]*<>"
  "String used to mark a heading to be rendered centered on the screen."
  :type 'string
  :group 'org-center)

(defun org-center-headings--center (center)
  "Update alignement of a heading at the point."
  (save-excursion
    (goto-char (line-beginning-position))
    (unless (re-search-forward org-leading-stars-re (line-end-position) t)
      (error "Not in org-heding."))
    (let ((end (line-end-position))
          (beg (line-beginning-position)))
      (if center
          (let* ((heading (buffer-substring beg end))
                 (length (/ (shr-string-pixel-width heading) 2)))
            (put-text-property
             beg (1+ beg) 'display `(space :align-to (- center (,length)))))
        (remove-text-properties beg (1+ beg) '(display nil))))))

(defun org-center-headings--center-all (center)
  "Update alignement of all org-headings in the buffer."
  (save-excursion
    (goto-char (point-min))
    (with-silent-modifications
      (while (re-search-forward org-leading-stars-re nil t)
        (org-center-headings--center center)))))

(defun org-center-headings--center-formatted (center)
  "Update alignement of all org-headings in the buffer."
  (save-excursion
    (goto-char (point-min))
    (with-silent-modifications
      (while (re-search-forward org-center-headings-marker-re nil t)
        (org-center-headings--center center)))))

(defun org-center-headings-center ()
  "Center heading at point."
  (interactive)
  (org-center-headings--center t))

(defun org-center-headings-remove-centering ()
  "Remove center alignement at point."
  (interactive)
  (org-center-headings--center nil))

(defun org-center-headings--hide-markers (visibility)
  (save-excursion
    (goto-char (point-min))
    (with-silent-modifications
      (while (re-search-forward org-center-headings-marker-re nil t)
        (put-text-property (- (point) 2) (point) 'invisible visibility)))))

;;;###autoload
(define-minor-mode org-center-headings-hide-markers
  "Hide/show <> markers in org-headings."
  :global nil :lighter " Org-hhm"
  (unless (derived-mode-p 'org-mode)
    (error "Not in org-mode"))
  (cond (org-center-headings-hide-markers
         (org-center-headings--hide-markers t))
        (t (org-center-headings--hide-markers nil))))

;;;###autoload
(define-minor-mode org-center-headings-mode
  "Hide/show babel source code blocks on demand."
  :global nil :lighter " Org-chm"
  (unless (derived-mode-p 'org-mode)
    (error "Not in org-mode"))
  (cond (org-center-headings-mode
         (if org-center-headings-formatted-only
             (org-center-headings--center-formatted t)
         (org-center-headings--center-all t)))
        (t (org-center-headings--center-all nil))))

(provide 'org-center-headings)
;;; org-center-headings.el ends here
