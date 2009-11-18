EMACS       = emacs

# Here's a sample rule for another project. Just change md-readme.el to
# the name of your elisp file. It needs md-readme.el is in your
# load-path, but allows you to pass LOAD_PATH to make. In our case, a
# simple "make LOAD_PATH=." should do the trick.

README.md: md-readme.el
	@$(EMACS) -q --no-site-file -batch \
		-eval "(mapc (lambda (dir) (add-to-list 'load-path dir)) (parse-colon-path (getenv \"LOAD_PATH\")))" \
		-l md-readme \
		-f mdr-generate-batch $< $@
