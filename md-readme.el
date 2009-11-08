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
;; Markdown. If you put your code on github, you can have this run
;; from a git pre-commit hook so you automatically have an up-to-date
;; README on github.

;; It recognizes headings, the GPL license disclaimer which is
;; replaced by a shorter notice linking to the GNU project's license
;; website, lists, and normal paragraph. Lists are somewhat tricky to
;; recognize automatically.

;;; Dependencies: none.

;;; Installation:
;; (require 'md-readme) in your init file, possibly in an
;; emacs-lisp-mode-hook.

;;; History:
;; 2009-11:    First release.

;;; Code:


; go through line by line.

; does not start with two ; and is not blank and "Code:" not yet
; encountered? error.

; three ;? # heading. remove : at the end.

; list? heuristic:
;  - if next line not empty, line length + length of next word < 70.
;  - More than one line starts with Capital:

; GPL notice? -> hard-coded text. Attention to version!

; in any case: just remove the ";; ".
