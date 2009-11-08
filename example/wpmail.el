;;; wpmail.el --- Post to wordpress by e-mail

;; Author: Thomas Kappler <tkappler@gmail.com>
;; Created: 2009 June 21
;; Keywords: wordpress, blog, blogging
;; URL: <http://github.com/thomas11/wpmail/tree/master>

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

;; A number of functions to make posting by e-mail to the
;; wordpress.com blog hosting service <http://www.wordpress.com>
;; easier.  It might work with other wordpress installations, which I
;; have not tried.  For more information about posting to wordpress by
;; e-mail see the support page
;; <http://support.wordpress.com/post-by-email/>.

;; Start a new post, possibly from the region or the buffer, with
;; wpmail-new-post, and send it with wpmail-send-post when you are
;; done.  wpmail-new-post will prompt for title and category; it will
;; propose some titles you can see via M-n, and auto-completes the
;; categories in wpmail-categories.  See the documentation of these
;; functions for details.

;;; Dependencies:
;; Message from Gnus.  It is included in Emacs, at least in version
;; 23.  Tested with Gnus v5.13.

;;; Installation:
;; Customize the variables at the top of the code section, and
;; (require 'wpmail) in your init file.

;;; History:
;; 2009-07:    First release.
;; 2009-11-03: Add post-configured-p and use it. Allow creating a new
;;             post in current buffer.

;;; TODO

;; When proposing the file name for a title, remove suffixes.

;; Add Markdown support, converting the post to HTML when sending.

;; Offer before- and after-send hooks, to allow things like
;; transforming the markup or saving all published posts in a certain
;; directory.

;;; Code:
(require 'message)

(defconst wpmail-posts-dir "~/Documents/Blog/jugglingbits.wordpress.com/posts"
  "The directory where you store your blog posts.
wpmail-new-post will open a new buffer visiting a file there.
Can be nil; you can always turn the current buffer into a blog
post with wpmail-new-post-here, and there is no need to save it
to a file.")

(defconst wpmail-post-email "FOO@post.wordpress.com"
  "The e-mail address you got from wordpress.com to send posts to.")

(defvar wpmail-categories '("Academia"
			    "Best Practices"
			    "Elsewhere"
			    "Links"
			    "Musings"
			    "Nitty Gritty"
			    "Own Code"
			    "Stuff"
			    "Theory")
  "A list of the categories you use for blog posts.
When starting a new post, wpmail will ask you for the category.
These will be available for tab completion.  You can also give a
category that is not in this list, but your wordpress must know
it.")

(defvar wpmail-default-tags "programming"
  "A list of post tags that will appear whenever you start a new post.")

(defconst wpmail-category-is-also-tag t
  "Non-nil means that initially a post's category will also be one of its tags.")


;; Some helpers that might go into a more general library.
;; -------------------------------------------------------

(defun wpmail-trim (string)
  "Remove leading and trailing whitespace from STRING.
From http://www.math.umd.edu/~halbert/dotemacs.html."
  (replace-regexp-in-string "\\(^[ \t\n]*\\|[ \t\n]*$\\)" "" string))

(defun wpmail-possible-titles ()
  "Make a list of suggestions for a blog post title.
The list contains at least the buffer name.  It also contains
some text around point, if it's not empty and not too long."
  (defun sensible-option-p (str)
    (and (stringp str) 
	 (< (length str) 60)
	 (> (length (wpmail-trim str)) 4)))

  (let ((options (list (buffer-name))))
    ;; Things at point
    (dolist (thing-kind (list 'word 'line 'sentence))
      (let ((option (thing-at-point thing-kind)))
    	(if (sensible-option-p option)
    	    (add-to-list 'options (wpmail-trim option)))))
    (delete-dups options)))

(defun wpmail-buffer-or-region ()
  "Return the region if it exists, the whole buffer otherwise."
  (if (use-region-p)
      (buffer-substring (region-beginning) (region-end))
    (buffer-substring (point-min) (point-max))))

;; End helpers ---------------------------------------------

(defvar wpmail-post-title "wpmail.el post"
  "The post's title when sending it off.
Will be set by `wpmail-new-post' or `wpmail-new-post-here'.")

(defun wpmail-new-post (title category init-content)
  "Start a new wordpress blog post in a new buffer.
The post will have the title TITLE and be in category CATEGORY.

The function proposes some titles based on the buffer name and
text around point, if any.  These propositions are in the
\"future history\", accessible by M-n.

In the category prompt, the values of wpmail-categories are
available for auto-completion.  You can also enter any category
that is not in wpmail-categories, but your wordpress must know
it.

A new buffer will be created, visiting the file TITLE.wp in
wpmail-posts-dir.  There is no need to save this file, however.
You can send it, with TITLE preserved, without saving it.

If INIT-CONTENT is non-nil (interactively, with prefix argument),
the new post buffer is filled with the region if it exists, and
with the whole content of the current buffer otherwise.

The new post buffer will contain a list of shortcodes, directives
the wordpress software evaluates when it receives the post. They
will be initialized to hopefully sensible values, but you should
check them before sending. In particular, you might wish to
change the post tags or the status. See
<http://support.wordpress.com/post-by-email/> for documentation
about shortcodes."
  (interactive (list 
		(read-string "Title: " nil nil (wpmail-possible-titles) nil)
		(completing-read "Category: " wpmail-categories)
		current-prefix-arg))
  (let ((content (if init-content (wpmail-buffer-or-region) nil)))
    (wpmail-initialize-new-file title category content)))

(defun wpmail-new-post-here (title category)
  "Start a new wordpress blog post in the current buffer.
It works like wpmail-new-post, except that everything happens in
the current buffer."
  (interactive (list 
		(read-string "Title: " nil nil (wpmail-possible-titles) nil)
		(completing-read "Category: " wpmail-categories)))
  (wpmail-initialize-this-buffer title category (point)))

(defun wpmail-initialize-new-file (title category content)
  "Does the actual work after wpmail-new-post got the user's input."
  (unless content (setq content ""))
  (wpmail-create-and-show-new-post-buffer title category content)
  (set-visited-file-name (wpmail-path-to-post-file title)))

(defun wpmail-path-to-post-file (title)
  "Find the path to a file with blog post TITLE.
The file will be in wpmail-posts-dir if non-nil, in the current
directory otherwise. The suffix depends on wpmail-use-markdown."
  (let ((dir (if wpmail-posts-dir wpmail-posts-dir ".")))
    (concat dir "/" title ".wp")))

(defun wpmail-create-and-show-new-post-buffer (title category content)
  "Create a new buffer named TITLE and initialize it."
  (let ((post-buffer (get-buffer-create title)))
    (set-buffer post-buffer)
    (wpmail-initialize-this-buffer title category (point-min))
    (switch-to-buffer post-buffer)))

(defun wpmail-initialize-this-buffer (title category restore-point)
  (let ((configured (wpmail-post-configured-p))
	(warning "This buffer seems to be initialized as a wordpress post already. New shortcodes will simply be added at the end. Continue?"))
    (when (or (not configured)
	      (and configured
		   (y-or-n-p warning)))
      (set (make-local-variable 'wpmail-post-title) title)
      (goto-char (point-max))
      (insert "\n\n"
	      (wpmail-initial-shortcodes category wpmail-default-tags))
      (goto-char restore-point))))

(defun wpmail-initial-shortcodes (category tags)
  "Return the wordpress shortcodes as a string; see wpmail-new-post."
  (mapconcat 'identity 
	     (list
	      (concat "[category " category "]")
	      (concat "[tags " tags 
		      (if wpmail-category-is-also-tag (concat "," category) "")
		      "]")
	      "[status draft]"
	      "-- "
	      "Anything after the signature line \"-- \" will not appear in the post."
	      "Status can be publish, pending, or draft."
	      "[slug some-url-name]"
	      "[excerpt]some excerpt[/excerpt]"
	      "[delay +1 hour]"
	      "[comments on | off]"
	      "[password secret-password]")
	     "\n"))

(defun wpmail-send-post ()
  "Send the post to wordpress.com by e-mail.
Partly copied from Trey Jackson
<http://stackoverflow.com/questions/679275/sending-email-in-emacs-programs>."
  (interactive)
  (let ((configured (wpmail-post-configured-p))
	(warning "This post doesn't seem to be configured yet; it lacks either a title or some wordpress shortcodes. (Initialize with wpmail-new-post-here.) Continue?"))
    (when (or configured
	      (and (not configured)
		   (y-or-n-p warning)))
      (let ((content (buffer-substring-no-properties (point-min) (point-max))))
	(message-mail wpmail-post-email wpmail-post-title)
	(message-goto-body)
	(insert content)
	(message-send-and-exit)))))

(defun wpmail-post-configured-p ()
  "Determine whether we're ready to send the current buffer."
  (and (boundp 'wpmail-post-title)
       (save-excursion
	 (goto-char (point-min))
	 (search-forward "[status " nil t))))


;; Unit tests, using el-expectations by rubikitch,
;; <http://www.emacswiki.org/emacs/EmacsLispExpectations>.
;; ---------------------------------------------------------

(eval-when-compile
  (when (fboundp 'expectations)
    (expectations
     
      ;; helpers

      (desc "trim")
      (expect "foo"
	(wpmail-trim "foo"))
      (expect "foo"
	(wpmail-trim "foo "))
      (expect "foo"
	(wpmail-trim " foo "))
      (expect "foo bar"
	(wpmail-trim " foo bar "))
     ; That'd be nice, but doesn't work with el-expectations.
     ; (dolist foo '("foo" " foo" "foo " " foo ")
     ;         (expect "foo" (wpmail-trim foo)))

     (desc "possible-titles contains buffer name")
     (expect (non-nil)
       (memq (buffer-name) (wpmail-possible-titles)))
     
     ;; wpmail

     (desc "post-configured-p")
     (expect nil
       (with-temp-buffer 
	 (wpmail-post-configured-p)))
     (expect (non-nil)
       (with-temp-buffer 
	 (set (make-local-variable 'wpmail-post-title) "title")
	 (insert "[status draft]")
	 (wpmail-post-configured-p)))

     (desc "initialize-this-buffer")
     (expect (non-nil)
       (with-temp-buffer 
	 (wpmail-initialize-this-buffer "title" "category" (point-min))
	 (wpmail-post-configured-p))))))

;; End unit tests. -----------------------------------------


(provide 'wpmail)
;;; wpmail.el ends here
