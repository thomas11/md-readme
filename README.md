# md-readme.el --- Markdown-formatted READMEs for your ELisp

* Author: Thomas Kappler <tkappler@gmail.com>
* Created: 2009 November 07
* Keywords: readme, markdown, header, documentation
* URL: <http://github.com/thomas11/md-readme/tree/master>

Copyright (C) 2009 Thomas Kappler

Licensed under the [GPL version 3](http://www.gnu.org/licenses/) or later.

# Commentary

The git-based source code hosting site <http://github.com> has
lately become popular for Emacs Lisp projects. Github has a feature
that displays files named "README" automatically on a project's
main page. If these files are formatted in Markdown, the formatting
is interpreted.

Emacs Lisp files customarily have a header in a fairly standardized
format. md-readme extracts this header and re-formats it to
Markdown. If you put your code on github, you could have this run
automatically, for instance upon saving the file or from a git
pre-commit hook, so you always have an up-to-date README on github.

It recognizes headings, the GPL license disclaimer which is
replaced by a shorter notice linking to the GNU project's license
website, lists, and normal paragraph. Lists are somewhat tricky to
recognize automatically.

# Dependencies
None.

# Installation
(require 'md-readme) in your init file, possibly in an
emacs-lisp-mode-hook.

# History
2009-11:    First release.


