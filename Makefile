all:

# ------ Environment ------

WGET = wget
PERL = perl
PERL_VERSION = latest
PERL_PATH = $(abspath local/perlbrew/perls/perl-$(PERL_VERSION)/bin)

PMB_PMTAR_REPO_URL =
PMB_PMPP_REPO_URL = 

Makefile-setupenv: Makefile.setupenv
	$(MAKE) --makefile Makefile.setupenv setupenv-update \
	    SETUPENV_MIN_REVISION=20120338

Makefile.setupenv:
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

lperl lprove lplackup local-perl perl-version perl-exec \
pmb-install pmb-update \
local-submodules generatepm: %: Makefile-setupenv
	$(MAKE) --makefile Makefile.setupenv $@

# ------ Tests ------

PROVE = prove
PERL_ENV = PATH="$(abspath ./local/perl-$(PERL_VERSION)/pm/bin):$(PERL_PATH):$(PATH)" PERL5LIB="$(shell cat config/perl/libs.txt)"

test: test-deps test-main

test-deps: local-submodules pmb-install

test-main:
	$(PERL_ENV) $(PROVE) t/*.t

# ------ Packaging ------

GENERATEPM = local/generatepm/bin/generate-pm-package

# XXX
dist: generatepm
	$(GENERATEPM) config/dist/hogehoge.pi dist/
