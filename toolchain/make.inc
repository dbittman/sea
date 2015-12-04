$(NAME)/$(REMOTEFILE): NAME:=$(NAME)
$(NAME)/$(REMOTEFILE): REMOTE:=$(REMOTE)
$(NAME)/$(REMOTEFILE): REMOTEFILE:=$(REMOTEFILE)
$(NAME)/$(REMOTEFILE):
	wget $(REMOTE) -O $(NAME)/$(REMOTEFILE)

$(NAME)/$(SOURCEDIR): NAME:=$(NAME)
$(NAME)/$(SOURCEDIR): REMOTEFILE:=$(REMOTEFILE)
$(NAME)/$(SOURCEDIR): SOURCEDIR:=$(SOURCEDIR)
$(NAME)/$(SOURCEDIR): $(NAME)/$(REMOTEFILE)
	(cd $(NAME) && tar xf $(REMOTEFILE))

$(NAME)/$(PATCHEDDIR): NAME:=$(NAME)
$(NAME)/$(PATCHEDDIR): PATCHFILE:=$(PATCHFILE)
$(NAME)/$(PATCHEDDIR): SOURCEDIR:=$(SOURCEDIR)
$(NAME)/$(PATCHEDDIR): PATCHEDDIR:=$(PATCHEDDIR)
$(NAME)/$(PATCHEDDIR): $(NAME)/$(PATCHFILE) $(NAME)/$(SOURCEDIR)
	if [ "$(PATCHFILE)" != "" ]; then \
		rm -r $(NAME)/$(PATCHEDDIR) 2>/dev/null ; \
		cp -r $(NAME)/$(SOURCEDIR) $(NAME)/$(PATCHEDDIR); \
		cd $(NAME)/$(PATCHEDDIR); \
		patch -p1 < ../$(PATCHFILE); \
		cd ..; \
	else \
		ln -s $(SOURCEDIR) $(NAME)/$(PATCHEDDIR); \
	fi

$(NAME)/$(BUILDDIR): BUILDDIR:=$(BUILDDIR)
$(NAME)/$(BUILDDIR): NAME:=$(NAME)
$(NAME)/$(BUILDDIR):
	mkdir -p $(NAME)/$(BUILDDIR)

clean-$(NAME): NAME:=$(NAME)
clean-$(NAME): BUILDDIR:=$(BUILDDIR)
clean-$(NAME):
	-rm -rf $(NAME)/$(BUILDDIR)

cleansrc-$(NAME): PATCHEDDIR:=$(PATCHEDDIR)
cleansrc-$(NAME): NAME:=$(NAME)
cleansrc-$(NAME):
	-$(MAKE) clean-$(NAME)
	-rm -rf $(NAME)/$(PATCHEDDIR)

distclean-$(NAME): NAME:=$(NAME)
distclean-$(NAME): SOURCEDIR:=$(SOURCEDIR)
distclean-$(NAME): REMOTEFILE:=$(REMOTEFILE)
distclean-$(NAME): cleansrc-$(NAME)
	-$(MAKE) cleansrc-$(NAME)
	-rm -rf $(NAME)/$(SOURCEDIR) $(NAME)/$(REMOTEFILE)


do-build-$(NAME): NAME:=$(NAME)
do-build-$(NAME): $(addprefix do-build-,$(DEPS))
	$(MAKE) build-$(NAME)

