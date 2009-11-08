# wpmail.el --- Post to wordpress by e-mail


* Author: Thomas Kappler <tkappler@gmail.com>
* Created: 2009 June 21
* Keywords: wordpress, blog, blogging
* URL: <http://github.com/thomas11/wpmail/tree/master>

Copyright (C) 2009 Thomas Kappler.  Licensed under the [GPL version
3](http://www.gnu.org/licenses/) or later.


# Commentary

A number of functions to make posting by e-mail to the
wordpress.com blog hosting service <http://www.wordpress.com>
easier.  It might work with other wordpress installations, which I
have not tried.  For more information about posting to wordpress by
e-mail see the support page
<http://support.wordpress.com/post-by-email/>.

Start a new post, possibly from the region or the buffer, with
wpmail-new-post, and send it with wpmail-send-post when you are
done.  wpmail-new-post will prompt for title and category; it will
propose some titles you can see via M-n, and auto-completes the
categories in wpmail-categories.  See the documentation of these
functions for details.

# Dependencies

* Message from Gnus.  It is included in Emacs, at least in version 23.
  Tested with Gnus v5.13.

# Installation

Customize the variables at the top of the code section, and
(require 'wpmail) in your init file.

# History:
* 2009-07:    First release.
* 2009-11-03: Add post-configured-p and use it. Allow creating a new
  post in current buffer.

# TODO

When proposing the file name for a title, remove suffixes.

Add Markdown support, converting the post to HTML when sending.

Offer before- and after-send hooks, to allow things like
transforming the markup or saving all published posts in a certain
directory.
