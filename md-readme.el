;;; md-readme.el --- Markdown-formatted READMEs for your ELisp

;; Author: Thomas Kappler <tkappler@gmail.com>
;; Created: 2009 November 07
;; Keywords: readme, markdown, header, documentation
;; URL: <http://github.com/thomas11/md-readme/tree/master>

;; Copyright (C) 2009 Thomas Kappler

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; The git-based source code hosting site <http://github.com> has
;; lately become popular for Emacs Lisp projects. Github has a feature
;; that displays files named "README" automatically on a project's
;; main page. If these files are formatted in Markdown, the formatting
;; is interpreted.

;; Emacs Lisp files customarily have a header in a fairly standardized
;; format. md-readme extracts this header and re-formats it to
;; Markdown. If you put your code on github, you could have this run
;; automatically, for instance upon saving the file or from a git
;; pre-commit hook, so you always have an up-to-date README on github.

;; It recognizes headings, the GPL license disclaimer which is
;; replaced by a shorter notice linking to the GNU project's license
;; website, lists, and normal paragraph. Lists are somewhat tricky to
;; recognize automatically.

;;; Dependencies:
;; None.

;;; Installation:
;; (require 'md-readme) in your init file, possibly in an
;; emacs-lisp-mode-hook.

;;; History:
;; 2009-11:    First release.

;;; Code:
(progn
  (set-buffer (mdr-put-header-in-temp-buffer))
  (mdr-convert-header)
)


(defun mdr-convert-header ()
  (goto-char (point-min))
  (mdr-find-and-replace-disclaimer)
  (while (< (line-number-at-pos) (line-number-at-pos (point-max)))
    (when (looking-at-p ";;")
      (delete-char 2)
      (cond ((looking-at-p ";")  ; heading
	     (delete-char 1)
	     (insert "#")
	     (progn
	       (end-of-line)
	       (backward-char)
	       (when (looking-at-p ":")
		 (delete-char 1))))
	    ((mdr-looking-at-list-p-2) (insert "*"))
	    (t (delete-char 1)) ; whitespace
	    )
      
      )
    (forward-line 1)))

(defun mdr-put-header-in-temp-buffer ()
  (let ((oldbuf (current-buffer))
	(oldbuf-start (point-min))
	(oldbuf-end-header (mdr-end-of-header)))
    (save-excursion
      (set-buffer (generate-new-buffer "md-readme-tmp.md"))
      (insert-buffer-substring oldbuf oldbuf-start oldbuf-end-header)
      (current-buffer))))

(defun mdr-end-of-header ()
  (save-excursion
    (goto-char (point-min))
    (while (or (looking-at-p "\n") (looking-at-p ";;"))
      (forward-line 1))
    (point)))

(defun mdr-looking-at-list-p ()
  (let ((next-line-word (mdr-next-line-first-word-length)))
    (insert next-line-word)
    (and (> next-line-word 0)
  	 (< (+ next-line-word (line-end-position)) 70))))

(defun mdr-looking-at-list-p-2 ()
  (looking-at-p " ?[a-zA-Z0-9]+:"))  ; why does [:alnum:] not work?

(defun mdr-next-line-first-word-length ()
  (save-excursion
    (forward-line 1)
    (when (looking-at-p ";;")
      (forward-char)
    (skip-chars-forward "^ ")))
(mdr-next-line-first-word-length)

(defun mdr-find-and-replace-disclaimer ()
  (save-excursion
    (goto-char (point-min))
    (when (search-forward "This program is free software" nil t)
      (let ((start-line (progn (beginning-of-line) (point)))
      	    (end-line (search-forward
      		       "If not, see <http://www.gnu.org/licenses/>."
      		       nil t)))
      	(delete-region start-line end-line)
      	(insert "Licensed under the [GPL version 3](http://www.gnu.org/licenses/) or later.")))))

; list? heuristic:
;  - if next line not empty, line length + length of next word < 70.
;  - More than one line starts with Capital:

(provide 'md-readme)
