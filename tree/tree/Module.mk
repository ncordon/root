# Module.mk for tree module
# Copyright (c) 2000 Rene Brun and Fons Rademakers
#
# Author: Fons Rademakers, 29/2/2000

MODNAME      := tree
MODDIR       := $(ROOT_SRCDIR)/tree/$(MODNAME)
MODDIRS      := $(MODDIR)/src
MODDIRI      := $(MODDIR)/inc

TREEDIR      := $(MODDIR)
TREEDIRS     := $(TREEDIR)/src
TREEDIRI     := $(TREEDIR)/inc

##### libTree #####
TREEL        := $(MODDIRI)/LinkDef.h
TREEDS       := $(call stripsrc,$(MODDIRS)/G__Tree.cxx)
TREEDO       := $(TREEDS:.cxx=.o)
TREEDH       := $(TREEDS:.cxx=.h)

TREEH        := $(filter-out $(MODDIRI)/LinkDef%,$(wildcard $(MODDIRI)/*.h $(MODDIRI)/ROOT/*.hxx))
TREES        := $(filter-out $(MODDIRS)/G__%,$(wildcard $(MODDIRS)/*.cxx))
TREEO        := $(call stripsrc,$(TREES:.cxx=.o))

TREEDEP      := $(TREEO:.o=.d) $(TREEDO:.o=.d)

TREELIB      := $(LPATH)/libTree.$(SOEXT)
TREEMAP      := $(TREELIB:.$(SOEXT)=.rootmap)

# used in the main Makefile
TREEH_REL   := $(patsubst $(MODDIRI)/%,include/%,$(TREEH))
ALLHDRS     += $(TREEH_REL)
ALLLIBS     += $(TREELIB)
ALLMAPS     += $(TREEMAP)
ifeq ($(CXXMODULES),yes)
  CXXMODULES_HEADERS := $(patsubst include/%,header \"%\"\\n,$(TREEH_REL))
  CXXMODULES_MODULEMAP_CONTENTS += module Tree_$(MODNAME) { \\n
  CXXMODULES_MODULEMAP_CONTENTS += $(CXXMODULES_HEADERS)
  CXXMODULES_MODULEMAP_CONTENTS += "export \* \\n"
  CXXMODULES_MODULEMAP_CONTENTS += link \"$(TREELIB)\" \\n
  CXXMODULES_MODULEMAP_CONTENTS += } \\n
endif

# include all dependency files
INCLUDEFILES += $(TREEDEP)

##### local rules #####
.PHONY:         all-$(MODNAME) clean-$(MODNAME) distclean-$(MODNAME)

include/%.h:    $(TREEDIRI)/%.h
		cp $< $@

include/%.hxx:  $(TREEDIRI)/%.hxx
		mkdir -p include/ROOT
		cp $< $@

$(TREELIB):     $(TREEO) $(TREEDO) $(ORDER_) $(MAINLIBS) $(TREELIBDEP)
		@$(MAKELIB) $(PLATFORM) $(LD) "$(LDFLAGS)" \
		   "$(SOFLAGS)" libTree.$(SOEXT) $@ "$(TREEO) $(TREEDO)" \
		   "$(TREELIBEXTRA) $(TBBLIBDIR) $(TBBLIB)"

$(call pcmrule,TREE)
	$(noop)

$(TREEDS):      $(TREEH) $(TREEL) $(ROOTCLINGEXE) $(call pcmdep,TREE)
		$(MAKEDIR)
		@echo "Generating dictionary $@..."
		$(ROOTCLINGSTAGE2) -f $@ $(call dictModule,TREE) -c -writeEmptyRootPCM $(TREEH) $(TREEL)

$(TREEMAP):     $(TREEH) $(TREEL) $(ROOTCLINGEXE) $(call pcmdep,TREE)
		$(MAKEDIR)
		@echo "Generating rootmap $@..."
		$(ROOTCLINGSTAGE2) -r $(TREEDS) $(call dictModule,TREE) -c $(TREEH) $(TREEL)

all-$(MODNAME): $(TREELIB)

clean-$(MODNAME):
		@rm -f $(TREEO) $(TREEDO)

clean::         clean-$(MODNAME)

distclean-$(MODNAME): clean-$(MODNAME)
		@rm -f $(TREEDEP) $(TREEDS) $(TREEDH) $(TREELIB) $(TREEMAP)

distclean::     distclean-$(MODNAME)

##### extra rules ######
ifeq ($(BUILDTBB),yes)
$(TREEO): CXXFLAGS += $(TBBINCDIR:%=-I%)
endif
