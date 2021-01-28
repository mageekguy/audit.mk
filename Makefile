# Disable builtin rules and variables, because they are useless in our context and add lot of noise when `make -d` is used to debug the macfly.
MAKEFLAGS+= --no-builtin-rules
MAKEFLAGS+= --no-builtin-variables

SHELL=bash

THIS_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
THIS_MAKEFILE=$(firstword $(MAKEFILE_LIST))
MKDIR:=mkdir -p
RM:=rm -rf
CP:=cp -r

DIRECTORY?=$(shell pwd)
TOP?=50
EXCLUDE:=-not -path "*/.git/*" -not -path "*/vendor/*" -not -path "*/.audit/*"
ALL_FILES:=$(shell find $(DIRECTORY) $(EXCLUDE) -type f | sed -e 's:$(DIRECTORY)/::g' -e 's: :\\ :g')

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

define summary
echo "==> $1: "$$($(call quote,$2) | xargs -n $$(getconf ARG_MAX) du -hsc | tail -n1 | cut -f1 | xargs)
echo "=> Number of files: "$$($(call count,$2))
echo "=> Top $(TOP): "
$(call humansize,$3)
echo
endef

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

.audit/files.duplicate.%: .audit/files.% .audit/files.duplicate
	echo -n "Find $* duplicate files… "
	cat $< | xargs -I@ egrep "@ " $^ | sort | uniq > $@
	echo "done!"

.audit/files.largest.%: .audit/files.%
	echo -n "Find largest $* files on file system… "
	$(call size,$<) > $@
	echo "done!"

.audit/files.%: .audit/files.all
	echo -n "Find $* files… "
	cat $< | egrep "\.$*$$" > $@ || > $@
	echo "done!"

audit: .audit/files.largest.all text json yaml css binaries html js images php encoding git duplicate cp ip ## Run the audit
	echo "==> EOL:"
	echo "=> DOS: $$($(call count,.audit/files.dos))"
	echo "=> unix: $$($(call count,.audit/files.unix))"
	echo "=> mac: $$($(call count,.audit/files.mac))"
	echo

	echo "==> Encoding: $$($(call count,.audit/encodings))"
	for encoding in $$(cat .audit/encodings); do echo "=> $$encoding: $$($(call count,.audit/$$encoding))"; done
	echo

	$(call summary,Disk usage,.audit/files.all,.audit/files.largest.all)
	$(call summary,JSON,.audit/files.json,.audit/files.largest.json)
	$(call summary,YAML,.audit/files.yaml,.audit/files.largest.yaml)
	$(call summary,HTML,.audit/files.html,.audit/files.largest.html)
	$(call summary,CSS,.audit/files.css,.audit/files.largest.css)
	$(call summary,JS,.audit/files.js,.audit/files.largest.js)
	$(call summary,Images,.audit/files.image,.audit/files.largest.image)
	$(call summary,Binaries,.audit/files.binary,.audit/files.largest.binary)
	$(call summary,PHP,.audit/files.php,.audit/files.largest.php)

	echo "==> $$(php --version | head -n 1 | cut -d\( -f1 | xargs) problems: $$($(call count,.audit/php.errors))"
	echo "=> Deprecated: $$(cat .audit/php.errors | grep -i " deprecated:" | $(call wc))"
	echo "=> Warning: $$(cat .audit/php.errors | grep -i " warning:" | $(call wc))"
	echo "=> Error: $$(cat .audit/php.errors | grep -i " error:" | $(call wc))"
	echo "=> PSR2 violations: $$(cat .audit/files.psr2 | $(call wc))"
	echo

	echo "==> Duplicates: $$($(call count,.audit/files.duplicate))"
	echo "=> PHP: $$($(call count,.audit/files.duplicate.php))"
	echo "=> JS: $$($(call count,.audit/files.duplicate.js))"
	echo "=> JSON: $$($(call count,.audit/files.duplicate.json))"
	echo "=> YAML: $$($(call count,.audit/files.duplicate.yaml))"
	echo "=> Images: $$($(call count,.audit/files.duplicate.image))"
	echo "=> Binaries: $$($(call count,.audit/files.duplicate.binary))"
	echo

	echo "==> PHP copy/paste: $$(cat .audit/files.php.cp | egrep "^[^%]*% duplicated lines")"
	echo

	echo "==> Git: $$(du -sh .git | cut -f1 | xargs)"
	echo "=> Current commit: $$(git rev-parse --short HEAD)"
	echo "=> Branches: $$($(call count,.audit/git.branches))"
	echo "=> First commit: $$(git log --all --reverse --format="format:%ci (%cr)" | sed -n 1p)"
	echo "=> Commits: $$(git rev-list --all --count)"
	echo "=> Commits without merge commits: $$(git rev-list --all --count --no-merges)"
	echo "=> Last commit: $$(git log --all --format="format:%ci (%cr)" | sed -n 1p)"
	echo "=> Tags: $$($(call count,.audit/git.tags))"
	echo "=> Authors: $$($(call count,.audit/git.authors))"
	echo
	git log -l0 --shortstat --no-merges | grep -E "fil(e|es) changed" | awk '{files+=$$1; inserted+=$$4; deleted+=$$6; delta+=$$4-$$6; ratio=deleted/inserted} END {printf "=> Commit stats:\nFiles changed: %s\nLines added: %s\nLines deleted: %s\nDelta: %s\nAdd./Del. ratio: 1/%s\n", files, inserted, deleted, delta, ratio }' -
	echo
	echo "=> Duplicated commit messages: $$(cat .audit/git.duplicate | $(call wc))"
	cat .audit/git.duplicate | head -n$(TOP)
	echo
	while IFS=":" read -r commit author; \
	do \
		printf \
			"%s\n%s\n%s\n%s\n" \
			"=> $$author: $$commit commit(s)" \
			"First commit: $$(git log --all --pretty=format:'%an@%cd (%cr)' --author="$$author" --date=local --reverse | egrep "^$$author@" | head -n1 | cut -d@ -f2)" \
			"Last commit: $$(git log --all --pretty=format:'%an@%cd (%cr)' --author="$$author" --date=local | egrep "^$$author@" | head -n1 | cut -d@ -f2)" \
			"$$(git log -l0 --all --shortstat --no-merges --author="$$(echo $$author | tr -s '\' '.')" | grep -E "fil(e|es) changed" | awk '{files+=$$1; inserted+=$$4; deleted+=$$6; delta+=$$4-$$6; ratio=deleted/inserted} END {printf "Files changed: %s\nLines added: %s\nLines deleted: %s\nDelta: %s\nAdd./Del. ratio: 1/%s\n", files, inserted, deleted, delta, ratio }' -)"; \
		echo; \
	done < .audit/git.authors

	echo "==> IP adresses and ports:"
	echo "=> IPs: $$($(call count,.audit/ip))"
	cat .audit/files.ip
	echo
	echo "=> Ports: $$($(call count,.audit/ports))"
	cat .audit/files.ports

.audit/files.all: $(ALL_FILES) | .audit/.
	echo -n "Find all files… "
	find $(DIRECTORY) $(EXCLUDE) -type f | sed -e 's:$(DIRECTORY)/::g' > $@
	echo "done!"

.audit/files.mime: .audit/files.all
	echo -n "Define type of all files… "
	$(call quote,.audit/files.all) | xargs file --mime-type > $@
	echo "done!"

.PHONY: text
text: .audit/files.largest.txt

.audit/files.txt: .audit/files.php .audit/files.css .audit/files.html .audit/files.json .audit/files.js .audit/files.yaml
	> $@
	for file in $^; do cat $$file >> $@; done

.PHONY: css
css: .audit/files.largest.css

.audit/files.css: .audit/files.all
	echo -n "Find $* files… "
	cat $< | egrep "\.css$$" | grep -v "\.min\.css" > $@ || > $@
	echo "done!"

.PHONY: json
json: .audit/files.largest.json

.PHONY: html
html: .audit/files.largest.html

.PHONY: js
js: .audit/files.largest.js

.audit/files.js: .audit/files.all
	echo -n "Find $* files… "
	cat $< | egrep "\.js$$" | grep -v "\.min\.js" > $@ || > $@
	echo "done!"

.PHONY: yaml
yaml: .audit/files.largest.yaml

.audit/files.yaml: .audit/files.all
	echo -n "Find YAML files… "
	cat $< | egrep "\.ya?ml$$" > $@ || > $@
	echo "done!"

.PHONY: binaries
binaries: .audit/files.largest.binary

.audit/files.binary: .audit/files.mime
	echo -n "Find binary files… "
	cat $< | egrep ": \s*application/octet-stream$$" | cut -d: -f1 > $@ || > $@
	echo "done!"

.PHONY: images
images: .audit/files.largest.image

.audit/files.image: .audit/files.mime
	echo -n "Find image files… "
	cat $< | egrep ": \s*image/.*$$" | grep -v ".php" | cut -d: -f1 > $@ || > $@
	echo "done!"

.PHONY: php
php: .audit/php.errors .audit/files.largest.php .audit/files.psr2

.audit/php.errors: .audit/files.php
	echo -n "Find syntax problem in PHP files… "
	cat $< | xargs -I@ -L1 sh -c "php -l "@" 1>/dev/null || exit 0" 2>$@
	echo "done!"

.audit/files.psr2: .audit/files.php .audit/.php_cs
	echo -n "Analyse coding style of PHP files according to PSR2… "
	cat $< | xargs -I@ echo '"@"' | xargs php -d memory_limit=-1 /usr/local/bin/php-cs-fixer fix --using-cache=no --verbose --dry-run --config=.audit/.php_cs 2>/dev/null | egrep "^[^)]*) " > $@
	echo "done!"

.audit/.php_cs: | .audit/.
	echo '<?php $$config = new PhpCsFixer\Config(); return $$config->setRules([ "@PSR2" => true ]);' > $@

.PHONY: encoding
encoding: .audit/encodings .audit/files.unix .audit/files.dos .audit/files.mac

.audit/files.analyze: .audit/files.txt
	echo -n "Prepare detection of encoding and EOL in text files… "
	$(call quote,$<) | xargs file > $@
	echo "done!"

.audit/files.unix: .audit/files.analyze
	echo -n "Detect UNIX EOL in text files… "
	cat $< | grep -v "CRLF line terminators" | grep -v "CR line terminators" | cut -d: -f1 > $@
	echo "done!"

.audit/files.mac: .audit/files.analyze
	echo -n "Detect MAC EOL in text files… "
	cat $< | grep "CR line terminators" | cut -d: -f1 > $@
	echo "done!"

.audit/files.dos: .audit/files.analyze
	echo -n "Detect DOS EOL in text files… "
	cat $< | grep "CRLF line terminators" | cut -d: -f1 > $@
	echo "done!"

.audit/files.encoding: .audit/files.txt
	echo -n "Detect encoding in text files… "
	$(call quote,$<) | xargs file --mime-encoding | tr -d ' ' > $@
	echo "done!"

.audit/encodings: .audit/files.encoding
	cat $< | cut -d: -f2 | tr -d ' ' | sort | uniq > .audit/encodings
	> /dev/null cd .audit && awk -F":\s*" '{print $$1>$$2}' files.encoding && > /dev/null cd -

.PHONY: git
git: .audit/git.authors .audit/git.branches .audit/git.tags .audit/git.duplicate

.audit/git.authors:
	echo -n "Extract authors… "
	git shortlog --no-merges -sn --all | sed -e 's/\(\d*\)\t/\1:/g' -e 's/^ *//' > $@
	echo "done!"

.audit/git.branches:
	echo -n "Extract Git branches… "
	git branch -r > $@
	echo "done!"

.audit/git.tags:
	echo -n "Extract Git tags… "
	git for-each-ref --sort=taggerdate --format '%(refname) %(taggerdate)' refs/tags > $@
	echo "done!"

.audit/git.duplicate:
	echo -n "Find duplicate Git commit messages… "
	git log --oneline --no-merges | cut -c 10- | sort -n -r | uniq -c | grep -v "1 " > $@
	echo "done!"

.PHONY: duplicate
duplicate: .audit/files.duplicate.php .audit/files.duplicate.js .audit/files.duplicate.css .audit/files.duplicate.json .audit/files.duplicate.yaml .audit/files.duplicate.image .audit/files.duplicate.binary

.audit/files.duplicate: $(call locate,fdupes)
	echo -n "Find duplicate files… "
	fdupes -r --sameline $(DIRECTORY) 2>/dev/null | sed -e "s#$(DIRECTORY)/##g" > $@
	echo "done!"

.PHONY: cp
cp: .audit/files.php.cp

.audit/files.php.cp: .audit/files.php | .audit/phpcpd.phar 
	echo -n "Find copy/paste in PHP files… "
	cat $< | xargs -I@ echo '"@"' | xargs php -d memory_limit=-1 .audit/phpcpd.phar --fuzzy | sed -e "s#$(DIRECTORY)#.#" > .audit/files.php.cp
	echo "done!"

.audit/phpcpd.phar: | .audit/. $(call locate,wget)
	echo -n "Install phpcpd… "
	wget --quiet https://phar.phpunit.de/phpcpd.phar -O $@ > /dev/null
	echo "done!"

.PHONY: ip
ip: .audit/ip .audit/ports

.audit/files.ip: .audit/files.txt
	echo -n "Find IP address in text files… "
	$(call xargs,$<) egrep -o -r "'(\d{1,3}\.){3}\d{1,3}'" | tr -d "'" | awk 'BEGIN {FS=":"} NF == 1 { print file": "$$1 } NF == 2 { print $$1": "$$2; file=$$1 }' > $@.tmp
	$(call xargs,$<) egrep -o -r '"(\d{1,3}\.){3}\d{1,3}"' | tr -d '"' | awk 'BEGIN {FS=":"} NF == 1 { print file": "$$1 } NF == 2 { print $$1": "$$2; file=$$1 }' >> $@.tmp
	$(call xargs,$<) egrep -o -r '@(\d{1,3}\.){3}\d{1,3}' | tr -d "@" | awk 'BEGIN {FS=":"} NF == 1 { print file": "$$1 } NF == 2 { print $$1": "$$2; file=$$1 }' >> $@.tmp
	$(call xargs,$<) egrep -o -r '//(\d{1,3}\.){3}\d{1,3}' | tr -d "/" | awk 'BEGIN {FS=":"} NF == 1 { print file": "$$1 } NF == 2 { print $$1": "$$2; file=$$1 }' >> $@.tmp
	$(call uniq,$@.tmp) > $@
	echo "done!"

.audit/files.ports: .audit/files.txt
	echo -n "Find IP port in text files… "
	$(call xargs,$<) egrep -o -r "'(\d{1,3}\.){3}\d{1,3}:\d{1,5}'" | tr -d "'" | awk 'BEGIN {FS=":"} NF == 2 { print file": "$$1 } NF == 3 { print $$1": "$$2":"$$3; file=$$1 }' > $@.tmp
	$(call xargs,$<) egrep -o -r '"(\d{1,3}\.){3}\d{1,3}:\d{1,5}"' | tr -d '"' | awk 'BEGIN {FS=":"} NF == 2 { print file": "$$1 } NF == 3 { print $$1": "$$2":"$$3; file=$$1 }' >> $@.tmp
	$(call xargs,$<) egrep -o -r '@(\d{1,3}\.){3}\d{1,3}:\d{1,5}' | tr -d "@" | awk 'BEGIN {FS=":"} NF == 2 { print file": "$$1 } NF == 3 { print $$1": "$$2":"$$3; file=$$1 }' >> $@.tmp
	$(call xargs,$<) egrep -o -r '//(\d{1,3}\.){3}\d{1,3}:\d{1,5}' | tr -d "/" | awk 'BEGIN {FS=":"} NF == 2 { print file": "$$1 } NF == 3 { print $$1": "$$2":"$$3; file=$$1 }' >> $@.tmp
	$(call uniq,$@.tmp) > $@
	echo "done!"

.audit/ip: .audit/files.ip
	cat $< | cut -d: -f2 | sort | uniq > $@

.audit/ports: .audit/files.ports
	cat $< | cut -d: -f2,3 | sort | uniq > $@

.PHONY: clean
clean: ## Delete `.audit` directory
	$(RM) .audit

.PHONY: reaudit
reaudit: ## Delete `.audit` directory and run the audit
	$(MAKE) -f $(THIS_MAKEFILE) clean
	$(MAKE) -f $(THIS_MAKEFILE) audit

.PHONY: help
help: ## <Help> Display this help.
	sed -e '/#\{2\} /!d; s/:[^#]*##/:/; s/\([^:]*\): <\([^>]*\)> \(.*\)/\2:\1:\3/; s/\([^:]*\): \([^<]*.*\)/Misc.:\1:\2/' $(MAKEFILE_LIST) | \
	sort -t: -d | \
	awk 'BEGIN{FS=":"; section=""} { if ($$1 != section) { section=$$1; printf "\n\033[1m%s\033[0m\n", $$1 } printf "\t\033[92m%s\033[0m:%s\n", $$2, $$3 }' | \
	column -c2 -t -s:
