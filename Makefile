# Disable builtin rules and variables, because they are useless in our context and add lot of noise when `make -d` is used to debug the macfly.
MAKEFLAGS+= --no-builtin-rules
MAKEFLAGS+= --no-builtin-variables

SHELL=bash

THIS_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
THIS_MAKEFILE=$(firstword $(MAKEFILE_LIST))
MKDIR:=mkdir -p
RM:=rm -rf
CP:=cp -r

NET_BROWSER?=Safari ## <Variables> your browser's name, default value is `Safari`
DIRECTORY?=$(shell pwd)
TOP?=50
PHPMETRICS_PHAR_URL?=https://github.com/phpmetrics/PhpMetrics/releases/download/v2.7.3/phpmetrics.phar
PHPCPD_PHAR_URL?=https://phar.phpunit.de/phpcpd.phar
LOCAL_PHP_SECURITY_CHECKER_URL?=https://github.com/fabpot/local-php-security-checker/releases/download/v1.0.0/local-php-security-checker_1.0.0_darwin_amd64
REPORT?=.audit/report.txt

FDUPES:=$(shell which fdupes || echo '/usr/local/bin/fdupes')
BREW:=$(shell which brew || echo '/usr/local/bin/brew')
WGET:=$(shell which wget || echo '/usr/local/bin/wget')
GIT:=$(or $(shell which git),$(error \`git\` is not in \`$(PATH)\`, please install it!))
GIT_COMMAND:=$(GIT) --git-dir=$(DIRECTORY)/.git
GIT_IGNORE:=$(shell $(GIT) config --global --get core.excludesfile || echo $(HOME)/.config/git/ignore)

EXCLUDE:=-not -path "*/.git/*" -not -path "*/vendor/*" -not -path "*/.audit/*"
ALL_FILES:=$(shell find $(DIRECTORY) $(EXCLUDE) -type f | sed -e 's:$(DIRECTORY)/::g' -e 's: :\\ :g')

WITH_ALL?=yes ## <Variables> `no` to not do a full audit, default value is `yes`

WITH_EOL?=$(WITH_ALL) ## <Variables> `yes` to audit end of lines, default value is value of `WITH_ALL` variable
ifeq ($(strip $(WITH_EOL)),yes)
REPORT_PARTS+= .audit/report.eol
endif

WITH_ENCODING?=$(WITH_ALL) ## <Variables> `yes` to audit files encoding, default value is value of `WITH_ALL` variable
ifeq ($(strip $(ENCODING)),yes)
REPORT_PARTS+= .audit/report.encoding
endif

WITH_DISK_USAGE?=$(WITH_ALL) ## <Variables> `yes` to audit disk usage, default value is value of `WITH_ALL` variable
ifeq ($(strip $(WITH_DISK_USAGE)),yes)
REPORT_PARTS+= .audit/report.disk
endif

WITH_PHP?=$(WITH_ALL) ## <Variables> `yes` to audit PHP files, default value is value of `WITH_ALL` variable
ifeq ($(strip $(WITH_PHP)),yes)
REPORT_PARTS+= .audit/report.php
endif

WITH_PHP_METRICS?=$(WITH_ALL) ## <Variables> `yes` to generate metrics about OOP in PHP files, default value is value of `WITH_ALL` variable
ifeq ($(strip $(WITH_PHP_METRICS)),yes)
REPORT_PARTS+= .audit/metrics
endif

WITH_DUPLICATED_FILES?=$(WITH_ALL) ## <Variables> `yes` to search duplicated files, default value is value of `WITH_ALL` variable
ifeq ($(strip $(WITH_DUPLICATED_FILES)),yes)
REPORT_PARTS+= .audit/report.duplicates
endif

WITH_COPY_PASTE?=$(WITH_ALL) ## <Variables> `yes` to search copy/paste pattern, default value is value of `WITH_ALL` variable
ifeq ($(strip $(WITH_COPY_PASTE)),yes)
REPORT_PARTS+= .audit/report.cp
endif

WITH_GIT?=$(WITH_ALL) ## <Variables> `yes` to audit git repository, default value is value of `WITH_ALL` variable
ifeq ($(strip $(WITH_GIT)),yes)
REPORT_PARTS+= .audit/report.git
endif

WITH_IP?=$(WITH_ALL) ## <Variables> `yes` to search IPs and ports in files, default value is value of `WITH_ALL` variable
ifeq ($(strip $(WITH_IP)),yes)
REPORT_PARTS+= .audit/report.ip
endif

define execute
echo -n "$1…"; $2; echo " done!"
endef

define phpcsfixer
$(call php) /usr/local/bin/php-cs-fixer fix --using-cache=no --verbose --dry-run --config=.audit/.php_cs 2>/dev/null | egrep '^[^\)]*\) '
endef

define size
$(call quote,$1) | xargs stat -f "%z\"%N" | sort -r -n | head -n $(TOP) | cut -d\" -f2 | sed -e "s:$(DIRECTORY)::g"
endef

define quote
cat $1 | xargs -I@ echo '"@"'
endef

define wc
wc -l | xargs
endef

define count
cat $1 | $(call wc)
endef

define humansize
$(call quote,$1) | xargs du -h
endef

define uniq
cat $1 | sort | uniq
endef

define xargs
cat $1 | xargs -I@ echo '"@"' | xargs
endef

define wget
$(WGET) --quiet $1 -O $2 > /dev/null
endef

define php
php -d memory_limit=-1 
endef

define details
echo "For more details, see:"; for file in $(filter .audit/%,$1); do echo "- $$file"; done
endef

define findIp
$(call xargs,$1) egrep -o -r $2 | tr -d $3 | awk 'BEGIN {FS=":"} NF == 1 { print file": "$$1 } NF == 2 { print $$1": "$$2; file=$$1 }'
endef

-include $(DIRECTORY)/.audit.mk

.SUFFIXES:

.DELETE_ON_ERROR:

.PRECIOUS: %/. .audit/phpcpd.phar

ifneq ($(WITH_DEBUG),)
OLD_SHELL := $(SHELL)
SHELL = $(warning $(if $@, Update target $@)$(if $<, from $<)$(if $?, due to $?))$(OLD_SHELL) -x
else
.SILENT:
endif

default: help

%/.:
	$(MKDIR) $@

.audit/.: $(GIT_IGNORE)
	$(MKDIR) $@; \
	echo "/.audit/" >> $(GIT_IGNORE); \
	echo "/.audit.mk" >> $(GIT_IGNORE); \
	cat $(GIT_IGNORE) | sort | uniq | tee $(GIT_IGNORE) > /dev/null

$(GIT_IGNORE):
	$(MKDIR) $(dir $@)

.audit/files.duplicate.%: .audit/files.% .audit/files.duplicate
	$(call execute,Find $* duplicate files,cat $< | xargs -I@ egrep "@ " $^ | sort | uniq > $@)

.audit/files.largest.%: .audit/files.%
	$(call execute,Find largest $* files on file system,$(call size,$<) > $@)

.audit/files.%: .audit/files.all
	$(call execute,Find $* files,cat $< | egrep "\.$*$$" > $@ || > $@)

.PHONY: audit
audit: $(REPORT) ## Run the audit

.audit/report.eol: .audit/files.dos .audit/files.unix .audit/files.mac
	( \
	echo "==> EOL:" && \
	echo "=> DOS: $$($(call count,.audit/files.dos))"; \
	echo "=> unix: $$($(call count,.audit/files.unix))"; \
	echo "=> mac: $$($(call count,.audit/files.mac))"; \
	echo \
	) | tee $@
	$(call details,$^)

.audit/report.encoding: .audit/encodings
	( \
	echo "==> Encoding: $$($(call count,.audit/encodings))" && \
	for encoding in $$(cat .audit/encodings); do echo "=> $$encoding: $$($(call count,.audit/$$encoding))"; done && \
	echo \
	) | tee $@
	$(call details,$^)

.audit/report.disk: .audit/report.disk.all .audit/report.disk.json .audit/report.disk.yaml .audit/report.disk.html .audit/report.disk.css .audit/report.disk.js .audit/report.disk.image .audit/report.disk.binary .audit/report.disk.php
	> $@
	for file in $^; do cat $$file >> $@; done

.audit/report.disk.%: .audit/files.% .audit/files.largest.%
	( \
	echo "==> $*: $$($(call quote,.audit/files.$*) | xargs -n $$(getconf ARG_MAX) du -hsc | tail -n1 | cut -f1 | xargs)"; \
	echo "=> Number of files: $$($(call count,.audit/files.$*))"; \
	echo "=> Top $(TOP):"; \
	$(call humansize,.audit/files.largest.$*); \
	) | tee $@;
	echo \
	$(call details,$^)
	echo

.audit/report.php: .audit/php.errors .audit/files.psr2 .audit/php.security
	( \
	echo "==> $$(php --version | head -n 1 | cut -d\( -f1 | xargs) problems: $$($(call count,.audit/php.errors))"; \
	echo "=> Deprecated: $$(cat .audit/php.errors | grep -i " deprecated:" | $(call wc))"; \
	echo "=> Warning: $$(cat .audit/php.errors | grep -i " warning:" | $(call wc))"; \
	echo "=> Error: $$(cat .audit/php.errors | grep -i " error:" | $(call wc))"; \
	echo "=> Security problems: $$(cat .audit/php.security | egrep '^[^ ]' | $(call wc))"; \
	cat .audit/php.security | egrep '^[^ ]' | cut -d: -f1; \
	echo "=> PSR2 violations: $$(cat .audit/files.psr2 | $(call wc))"; \
	echo \
	) | tee $@
	$(call details,$^)

.audit/report.duplicates: .audit/files.duplicate .audit/files.duplicate.php .audit/files.duplicate.js .audit/files.duplicate.css .audit/files.duplicate.html .audit/files.duplicate.json .audit/files.duplicate.yaml .audit/files.duplicate.image .audit/files.duplicate.binary
	( \
	echo "==> Duplicates: $$($(call count,.audit/files.duplicate))"; \
	echo "=> PHP: $$($(call count,.audit/files.duplicate.php))"; \
	echo "=> JS: $$($(call count,.audit/files.duplicate.js))"; \
	echo "=> CSS: $$($(call count,.audit/files.duplicate.css))"; \
	echo "=> HTML: $$($(call count,.audit/files.duplicate.html))"; \
	echo "=> JSON: $$($(call count,.audit/files.duplicate.json))"; \
	echo "=> YAML: $$($(call count,.audit/files.duplicate.yaml))"; \
	echo "=> Images: $$($(call count,.audit/files.duplicate.image))"; \
	echo "=> Binaries: $$($(call count,.audit/files.duplicate.binary))"; \
	echo \
	) | tee $@
	$(call details,$^)

.audit/report.cp: .audit/files.php.cp
	( \
	echo "==> PHP copy/paste: $$(cat .audit/files.php.cp | egrep "^[^%]*% duplicated lines")"; \
	echo \
	) | tee $@
	$(call details,$^)

.audit/report.git: .audit/git.authors .audit/git.branches .audit/git.tags .audit/git.duplicate $(GIT)
	( \
	echo "==> Git: $$(du -sh .git | cut -f1 | xargs)"; \
	echo "=> Current commit: $$($(GIT_COMMAND) rev-parse --short HEAD)"; \
	echo "=> Branches: $$($(call count,.audit/git.branches))"; \
	echo "=> First commit: $$($(GIT_COMMAND) log --all --reverse --format="format:%ci (%cr)" | sed -n 1p)"; \
	echo "=> Commits: $$($(GIT_COMMAND) rev-list --all --count)"; \
	echo "=> Commits without merge commits: $$($(GIT_COMMAND) rev-list --all --count --no-merges)"; \
	echo "=> Last commit: $$($(GIT_COMMAND) log --all --format="format:%ci (%cr)" | sed -n 1p)"; \
	echo "=> Tags: $$($(call count,.audit/git.tags))"; \
	echo "=> Authors: $$($(call count,.audit/git.authors))"; \
	echo; \
	$(GIT_COMMAND) log -l0 --shortstat --no-merges | grep -E "fil(e|es) changed" | awk '{files+=$$1; inserted+=$$4; deleted+=$$6; delta+=$$4-$$6; ratio=deleted/inserted} END {printf "=> Commit stats:\nFiles changed: %s\nLines added: %s\nLines deleted: %s\nDelta: %s\nAdd./Del. ratio: 1/%s\n", files, inserted, deleted, delta, ratio }' -; \
	echo; \
	echo "=> Duplicated commit messages: $$(cat .audit/git.duplicate | $(call wc))"; \
	cat .audit/git.duplicate | head -n$(TOP); \
	echo; \
	while IFS=":" read -r commit author; \
	do \
		printf \
			"%s\n%s\n%s\n%s\n" \
			"=> $$author: $$commit commit(s)" \
			"First commit: $$($(GIT_COMMAND) log --all --pretty=format:'%an@%cd (%cr)' --author="$$author" --date=local --reverse | egrep "^$$author@" | head -n1 | cut -d@ -f2)" \
			"Last commit: $$($(GIT_COMMAND) log --all --pretty=format:'%an@%cd (%cr)' --author="$$author" --date=local | egrep "^$$author@" | head -n1 | cut -d@ -f2)" \
			"$$($(GIT_COMMAND) log -l0 --all --shortstat --no-merges --author="$$(echo $$author | tr -s '\' '.')" | grep -E "fil(e|es) changed" | awk '{files+=$$1; inserted+=$$4; deleted+=$$6; delta+=$$4-$$6; ratio=deleted/inserted} END {printf "Files changed: %s\nLines added: %s\nLines deleted: %s\nDelta: %s\nAdd./Del. ratio: 1/%s\n", files, inserted, deleted, delta, ratio }' -)"; \
		echo; \
	done < .audit/git.authors \
	) | tee $@
	$(call details,$^)

.audit/report.ip: .audit/ip .audit/ports
	( \
	echo "==> IP adresses and ports:"; \
	echo "=> IPs: $$($(call count,.audit/ip))"; \
	cat .audit/ip; \
	echo; \
	echo "=> Ports: $$($(call count,.audit/ports))"; \
	cat .audit/ports; \
	) | tee $@
	$(call details,$^)

.PHONY: report
report: $(REPORT)
	echo "Report is available in $(REPORT)!"

$(REPORT): $(REPORT_PARTS)
	> $@; \
	for file in $(filter report.%,$(REPORT_PARTS)); do cat $$file >> $@; done

.audit/files.all: $(ALL_FILES) | .audit/.
	$(call execute,Find all files,find $(DIRECTORY) $(EXCLUDE) -type f | sed -e 's:$(DIRECTORY)/::g' > $@)

.audit/files.mime: .audit/files.all
	$(call execute,Define type of all files,$(call quote,.audit/files.all) | xargs file --mime-type > $@)

.PHONY: text
text: .audit/files.largest.txt

.audit/files.txt: .audit/files.php .audit/files.css .audit/files.html .audit/files.json .audit/files.js .audit/files.yaml
	> $@; \
	for file in $^; do cat $$file >> $@; done

.PHONY: css
css: .audit/files.largest.css

.audit/files.css: .audit/files.all
	$(call execute,Find CSS files,cat $< | egrep "\.css$$" | grep -v "\.min\.css" > $@ || > $@)

.PHONY: json
json: .audit/files.largest.json

.PHONY: html
html: .audit/files.largest.html

.PHONY: js
js: .audit/files.largest.js

.audit/files.js: .audit/files.all
	$(call execute,Find JS files,cat $< | egrep "\.js$$" | grep -v "\.min\.js" > $@ || > $@)

.PHONY: yaml
yaml: .audit/files.largest.yaml

.audit/files.yaml: .audit/files.all
	$(call execute,Find YAML files,cat $< | egrep "\.ya?ml$$" > $@ || > $@)

.PHONY: binaries
binaries: .audit/files.largest.binary

.audit/files.binary: .audit/files.mime
	$(call execute,Find binary files,cat $< | egrep ": \s*application/octet-stream$$" | cut -d: -f1 > $@ || > $@)

.PHONY: images
images: .audit/files.largest.image

.audit/files.image: .audit/files.mime
	$(call execute,Find image files,cat $< | egrep ": \s*image/.*$$" | grep -v ".php" | cut -d: -f1 > $@ || > $@)

.PHONY: php
php: .audit/php.errors .audit/files.largest.php .audit/files.psr2

.audit/php.errors: .audit/files.php
	$(call execute,Find syntax problem in PHP files,cat $< | xargs -I@ -L1 sh -c "php -l "@" 1>/dev/null || exit 0" 2>$@)

.audit/files.psr2: .audit/files.php .audit/.php_cs
	$(call execute,Analyse coding style of PHP files according to PSR2,cat $< | xargs -I@ echo '"@"' | xargs $(call phpcsfixer) > $@)

.audit/.php_cs: | .audit/.
	echo '<?php $$config = new PhpCsFixer\Config(); return $$config->setRules([ "@PSR2" => true ]);' > $@

.PHONY: encoding
encoding: .audit/encodings .audit/files.unix .audit/files.dos .audit/files.mac

.audit/files.analyze: .audit/files.txt
	$(call execute,Prepare detection of encoding and EOL in text files,$(call quote,$<) | xargs file > $@)

.audit/files.unix: .audit/files.analyze
	$(call execute,Detect UNIX EOL in text files,cat $< | grep -v "CRLF line terminators" | grep -v "CR line terminators" | cut -d: -f1 > $@)

.audit/files.mac: .audit/files.analyze
	$(call execute,Detect MAC EOL in text files,cat $< | grep "CR line terminators" | cut -d: -f1 > $@)

.audit/files.dos: .audit/files.analyze
	$(call execute,Detect DOS EOL in text files,cat $< | grep "CRLF line terminators" | cut -d: -f1 > $@)

.audit/files.encoding: .audit/files.txt
	$(call execute,Detect encoding in text files,$(call quote,$<) | xargs file --mime-encoding | tr -d ' ' > $@)

.audit/encodings: .audit/files.encoding
	cat $< | cut -d: -f2 | tr -d ' ' | sort | uniq > .audit/encodings; \
	> /dev/null cd .audit && awk -F":\s*" '{print $$1>$$2}' files.encoding && > /dev/null cd -

.PHONY: git
git: .audit/git.authors .audit/git.branches .audit/git.tags .audit/git.duplicate

.audit/git.authors: | $(GIT) .audit/.
	$(call execute,Extract authors,$(GIT_COMMAND) shortlog --no-merges -sn --all | sed -e 's/\(\d*\)\t/\1:/g' -e 's/^ *//' > $@)

.audit/git.branches: | $(GIT)
	$(call execute,Extract Git branches,$(GIT_COMMAND) branch -r > $@)

.audit/git.tags: | $(GIT)
	$(call execute,Extract Git tags,$(GIT_COMMAND) for-each-ref --sort=taggerdate --format '%(refname) %(taggerdate)' refs/tags > $@)

.audit/git.duplicate: | $(GIT)
	$(call execute,Find duplicate Git commit messages,$(GIT_COMMAND) log --format="%s" --no-merges | sort | uniq -c | grep -v "1 " | sort -rn > $@)

.PHONY: duplicate
duplicate: .audit/files.duplicate.php .audit/files.duplicate.js .audit/files.duplicate.css .audit/files.duplicate.json .audit/files.duplicate.yaml .audit/files.duplicate.image .audit/files.duplicate.binary

.audit/files.duplicate: | $(FDUPES)
	$(call execute,Find duplicate files,$(FDUPES) -r --sameline $(DIRECTORY) 2>/dev/null | sed -e "s#$(DIRECTORY)/##g" > $@)

$(FDUPES): | $(BREW)
	$(BREW) install fdupes

.PHONY: cp
cp: .audit/files.php.cp

.audit/files.php.cp: .audit/files.php | .audit/phpcpd.phar 
	$(call execute,Find copy/paste in PHP files,cat $< | xargs -I@ echo '"@"' | xargs $(call php) .audit/phpcpd.phar --fuzzy | sed -e "s#$(DIRECTORY)#.#" > .audit/files.php.cp)

.audit/phpcpd.phar: | .audit/. $(WGET)
	$(call execute,Install phpcpd,$(call wget,$(PHPCPD_PHAR_URL),$@))

.PHONY: ip
ip: .audit/ip .audit/ports

.audit/files.ip: .audit/files.txt
	$(call execute,Find IP address in text files,> $@; $(call findIp,$<,$(strip "'(\d{1,3}\.){3}\d{1,3}'"),"'") >> $@; $(call findIp,$<,$(strip '"(\d{1,3}\.){3}\d{1,3}"'),'"') >> $@; $(call findIp,$<,$(strip '@(\d{1,3}\.){3}\d{1,3}'),'@') >> $@; $(call findIp,$<,$(strip '//(\d{1,3}\.){3}\d{1,3}'),'/') >> $@; $(call uniq,$@) | tee $@ > /dev/null)

.audit/files.ports: .audit/files.txt
	$(call execute,Find IP port in text files,> $@; $(call findIp,$<,$(strip "'(\d{1,3}\.){3}\d{1,3}:\d{1,5}'"),"'") >> $@; $(call findIp,$<,$(strip '"(\d{1,3}\.){3}\d{1,3}:\d{1,5}"'),'"') >> $@; $(call findIp,$<,$(strip '@(\d{1,3}\.){3}\d{1,3}:\d{1,5}'),"@") >> $@; $(call findIp,$<,$(strip '//(\d{1,3}\.){3}\d{1,3}:\d{1,5}'),'/') >> $@; $(call uniq,$@) | tee $@ > /dev/null)

.audit/ip: .audit/files.ip
	cat $< | cut -d: -f2 | tr -d ' ' | sort | uniq > $@

.audit/ports: .audit/files.ports
	cat $< | cut -d: -f2,3 | tr -d ' ' | sort | uniq > $@

.PHONY: metrics
metrics: .audit/metrics

.audit/metrics: | .audit/phpmetrics.phar
	$(call execute,Run phpmetrics,$(call php) /usr/local/bin/phpmetrics --quiet --report-html=$@ $(DIRECTORY))
	open -a $(NET_BROWSER) -g $@/index.html

.audit/phpmetrics.phar: | .audit/. $(WGET)
	$(call execute,Install phpmetrics,$(call wget,$(PHPMETRICS_PHAR_URL),$@))

.audit/php.security: | .audit/local-php-security-checker
	find $(DIRECTORY) -type f -name composer.lock | xargs -I@ .audit/local-php-security-checker --path @ --format=yaml | grep -v '{}' | tee $@

.audit/local-php-security-checker: | .audit/. $(WGET)
	$(call execute,Install local-php-security-checker,$(call wget,$(LOCAL_PHP_SECURITY_CHECKER_URL),$@) && chmod u+x $@)

$(GIT): | $(BREW)
	$(BREW) install git

$(WGET): | $(BREW)
	$(BREW) install wget

$(BREW):
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: clean
clean: ## Delete `.audit` directory
	$(RM) .audit

.PHONY: reaudit
reaudit: ## Delete `.audit` directory and run the audit
	$(MAKE) -f $(THIS_MAKEFILE) clean
	$(MAKE) -f $(THIS_MAKEFILE) audit

.PHONY: help
help: ## <Help> Display this help.
	sed -e '/#\{2\} /!d; s/[?=:][^#]*##/:/; s/# *\([^#]\+\)##/\1:/; s/\([^:?]*\): <\([^>]*\)> \(.*\)/\2:\1:\3/; s/\([^:]*\): \([^<]*.*\)/Misc.:\1:\2/' $(MAKEFILE_LIST) | \
	sort -t: -d | \
	awk 'BEGIN{FS=":"; section=""} { if ($$1 != section) { section=$$1; printf "\n\033[1m%s\033[0m\n", $$1 } printf "\t\033[92m%s\033[0m:%s\n", $$2, $$3 }' | \
	column -c2 -t -s :
