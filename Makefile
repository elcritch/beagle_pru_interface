SRCDIRS = src
# TEST_SUBDIRS = test/pru_msg

export ARTIFACT_DIR = _build/pru

ifeq ($(MIX_ENV),test)
SUBDIRS += $(TEST_BUDIRS)
endif

all: $(SRCDIRS)

$(SRCDIRS): _priv
	$(MAKE) -C $@

artifact: $(SUBDIRS)

test: $(TEST_SUBDIRS)

_priv:
	mkdir -p priv/

# $(TEST_SUBDIRS): 
	# $(MAKE) -C $@

clean: 
	@for d in $(SRCDIRS); do (cd $$d; $(MAKE) clean ); done
	# @for d in $(TEST_SUBDIRS); do (cd $$d; $(MAKE) clean ); done

.PHONY: $(SUBDIRS)
