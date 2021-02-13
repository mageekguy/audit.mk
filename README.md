# A makefile to extract some metrics from a PHP Project

## Features

- Check EOL;
- Check encoding;
- Find largest files (PHP, JS, JSON, CSS, HTML, images, binaries);
- Find duplicated files (PHP, JS, JSON, CSS, HTML, images, binaries);
- Check PHP syntax;
- Check PHP files coding style according to PSR2;
- Check if PHP code depends on PHP packages with known security vulnerabilities;
- Extract some metrics about OOP;
- Find copy/paste code;
- Find commits number, branches, tags, authors, first commit and last commit in a Git repository;
- Find commits number, branches, tags, authors, first commit and last commit for each authors in a Git repository;
- Find duplicated commit messages;
- Search hardcoded IP addresses;
- Generate graphes about git repository (commits frequency by hour, day, months, number of commits for each commiter).

# Requirements

Requirements to use `audit.mk` are:

- OSX;
- [GNU Make](https://www.gnu.org/software/make/);
- [git](https://git-scm.com);
- bash.

Moreover, some utility tools like `awk` and `sed` are mandatory.  
And `audit.mk` was develop using OSX, so it is currently incompatible with Linux/Windows (but it is POSIX compliant, so if you want to use it on Linux, do the PR ;)).  
Finally, if some tools used by `audit.mk` are not available, `brew` will be installed and used to install missing tools.

# Installation

1. Clone the repository somewhere on your file system;
2. Do `make -f path/to/audit.mk audit` in the folder of your PHP project.

A directory named `.audit` will be created and a report will be displayed after a few moment (the analyze can take long time according to the size of your project).  
The directory contains some interesting files used to generate the report.  
It is possible to define some audit area, for example the following command do an audit only about PHP files and git repository:

```
$ make -f path/to/audit.mk audit WITH_ALL=no WITH_GIT=yes WITH_PHP=yes
````

Do `make help` for more informations.

# Tips

You can do `make  -f path/to/audit.mk audit WITH_DEBUG=true` to have (lot of) more informations about the audit process.  
You can create a `.audit.mk` at the root of audited project directory to add some specific targets.

# FAQ

## Why using GNU Make to audit PHP project?

To avoid rebuild of all files used to generate the report on each run or when the project was updated. And… `make` is fun and powerful, no?

# Report example

Below is a report made against the [atoum](https://github.com/atoum/atoum) project:

```
==> EOL:
=> DOS: 0
=> unix: 575
=> mac: 0

==> all: 5.0M
=> Number of files: 618
=> Top 50:
152K	tests/units/classes/mock/generator.php
 72K	tests/units/classes/test.php
 68K	tests/units/classes/asserters/phpArray.php
 68K	classes/test.php
 64K	tests/units/classes/score/coverage.php
 64K	tests/units/classes/test/adapter/calls.php
 60K	tests/units/classes/score.php
 60K	tests/units/classes/asserters/mock.php
 56K	tests/units/classes/mock/streams/fs/file/controller.php
 52K	tests/units/classes/mock/stream/controller.php
 52K	tests/units/classes/asserters/adapter.php
 52K	tests/units/classes/scripts/runner.php
 48K	classes/scripts/runner.php
 44K	tests/units/classes/php/tokenizer/iterator.php
 44K	tests/units/classes/fs/path.php
 40K	tests/units/classes/report/fields/runner/errors/cli.php
 40K	classes/mock/generator.php
 36K	tests/units/classes/scripts/builder.php
 36K	tests/units/classes/runner.php
 36K	tests/units/classes/template/parser.php
 32K	tests/units/classes/asserters/variable.php
 32K	tests/units/classes/asserters/phpString.php
 32K	tests/units/classes/template.php
 32K	tests/units/classes/report/fields/runner/coverage/html.php
 32K	tests/units/classes/script.php
 32K	tests/units/resources/phing/AtoumTask.php
 32K	tests/units/classes/script/arguments/parser.php
 28K	tests/units/classes/asserters/phpClass.php
 28K	tests/units/classes/report/fields/test/event/tap.php
 28K	tests/units/classes/test/adapter.php
 28K	tests/units/classes/mock/controller.php
 24K	classes/runner.php
 24K	classes/score/coverage.php
 24K	tests/units/classes/asserters/utf8String.php
 24K	classes/scripts/builder.php
 24K	classes/scripts/phar/stub.php
 24K	tests/units/classes/mock/streams/fs/file.php
 20K	tests/units/classes/asserters/dateTime.php
 20K	CHANGELOG.md
 20K	tests/units/classes/asserters/phpObject.php
 20K	tests/units/classes/scripts/phar/generator.php
 20K	tests/units/classes/report/fields/runner/result/cli.php
 20K	tests/units/classes/scripts/coverage.php
 20K	tests/units/classes/asserters/error.php
 20K	tests/units/classes/scripts/builder/vcs/svn.php
 20K	tests/units/classes/asserters/exception.php
 20K	README.md
 20K	tests/units/classes/test/adapter/invoker.php
 20K	tests/units/classes/report/fields/runner/failures/cli.php
 20K	tests/units/classes/php/tokenizer.php

 ==> json: 24K
=> Number of files: 6
=> Top 50:
4.0K	composer.json
4.0K	tests/units/classes/reports/asynchronous/coveralls/resources/3.json
4.0K	tests/units/classes/reports/asynchronous/coveralls/resources/3-windows.json
4.0K	tests/units/classes/reports/asynchronous/coveralls/resources/2.json
4.0K	tests/units/classes/reports/asynchronous/coveralls/resources/2-windows.json
4.0K	tests/units/classes/reports/asynchronous/coveralls/resources/1.json

==> yaml: 16K
=> Number of files: 4
=> Top 50:
4.0K	appveyor.yml
4.0K	.github/workflows/linux.yml
4.0K	.styleci.yml
4.0K	.codeclimate.yml

==> html: 24K
=> Number of files: 2
=> Top 50:
 12K	resources/treemap/index.html
 12K	resources/coverage/treemap/index.html

 ==> css: 4.0K
=> Number of files: 1
=> Top 50:
4.0K	resources/templates/coverage/screen.css

==> js: 
=> Number of files: 0
=> Top 50:
==> image: 12K
=> Number of files: 3
=> Top 50:
4.0K	resources/images/logo/success.png
4.0K	resources/images/logo/failure.png
4.0K	resources/images/logo.png

==> binary: 52K
=> Number of files: 6
=> Top 50:
 12K	classes/.DS_Store
 12K	resources/.DS_Store
8.0K	tests/.DS_Store
8.0K	scripts/.DS_Store
8.0K	.DS_Store
4.0K	tests/units/classes/scripts/git/.tag

==> php: 4.7M
=> Number of files: 562
=> Top 50:
152K	tests/units/classes/mock/generator.php
 72K	tests/units/classes/test.php
 68K	tests/units/classes/asserters/phpArray.php
 68K	classes/test.php
 64K	tests/units/classes/score/coverage.php
 64K	tests/units/classes/test/adapter/calls.php
 60K	tests/units/classes/score.php
 60K	tests/units/classes/asserters/mock.php
 56K	tests/units/classes/mock/streams/fs/file/controller.php
 52K	tests/units/classes/mock/stream/controller.php
 52K	tests/units/classes/asserters/adapter.php
 52K	tests/units/classes/scripts/runner.php
 48K	classes/scripts/runner.php
 44K	tests/units/classes/php/tokenizer/iterator.php
 44K	tests/units/classes/fs/path.php
 40K	tests/units/classes/report/fields/runner/errors/cli.php
 40K	classes/mock/generator.php
 36K	tests/units/classes/scripts/builder.php
 36K	tests/units/classes/runner.php
 36K	tests/units/classes/template/parser.php
 32K	tests/units/classes/asserters/variable.php
 32K	tests/units/classes/asserters/phpString.php
 32K	tests/units/classes/template.php
 32K	tests/units/classes/report/fields/runner/coverage/html.php
 32K	tests/units/classes/script.php
 32K	tests/units/resources/phing/AtoumTask.php
 32K	tests/units/classes/script/arguments/parser.php
 28K	tests/units/classes/asserters/phpClass.php
 28K	tests/units/classes/report/fields/test/event/tap.php
 28K	tests/units/classes/test/adapter.php
 28K	tests/units/classes/mock/controller.php
 24K	classes/runner.php
 24K	classes/score/coverage.php
 24K	tests/units/classes/asserters/utf8String.php
 24K	classes/scripts/builder.php
 24K	classes/scripts/phar/stub.php
 24K	tests/units/classes/mock/streams/fs/file.php
 20K	tests/units/classes/asserters/dateTime.php
 20K	tests/units/classes/asserters/phpObject.php
 20K	tests/units/classes/scripts/phar/generator.php
 20K	tests/units/classes/report/fields/runner/result/cli.php
 20K	tests/units/classes/scripts/coverage.php
 20K	tests/units/classes/asserters/error.php
 20K	tests/units/classes/scripts/builder/vcs/svn.php
 20K	tests/units/classes/asserters/exception.php
 20K	tests/units/classes/test/adapter/invoker.php
 20K	tests/units/classes/report/fields/runner/failures/cli.php
 20K	tests/units/classes/php/tokenizer.php
 20K	tests/units/classes/asserters/iterator.php
 20K	tests/units/classes/cli/commands/git.php

==> PHP 7.4.0 problems: 2
=> Deprecated: 0
=> Warning: 0
=> Error: 2
=> Security problems: 0
=> PSR2 violations: 22

==> Duplicates: 9
=> PHP: 0
=> JS: 0
=> CSS: 0
=> HTML: 0
=> JSON: 0
=> YAML: 0
=> Images: 0
=> Binaries: 0

==> PHP copy/paste: 8.19% duplicated lines out of 89593 total lines of code.

==> Git: 11M
=> Current commit: c4214d1b
=> Branches: 23
=> First commit: 2010-05-28 09:55:59 +0000 (11 years ago)
=> Commits: 3303
=> Commits without merge commits: 2883
=> Last commit: 2021-01-14 19:13:00 +0100 (4 weeks ago)
=> Tags: 40
=> Authors: 85

=> Commit stats:
Files changed: 11990
Lines added: 341597
Lines deleted: 227129
Delta: 114468
Add./Del. ratio: 1/0.664903

=> Duplicated commit messages: 194
  42 Cleaning.
  22 __toString Refactoring for fields
  22 Set version to dev-master.
  10 Optimization.
   9 Update changelog
   9 Refactoring.
   9 Improve unit tests.
   9 Cleaning
   8 Clean
   7 No more decorators
   6 Update README.md
   6 Remove useless methods.
   6 Remove useless method.
   6 Improve unit test.
   6 Add changelog entry
   5 Typo
   5 Remove dependencies.
   4 Remove functional testing and put it into a dedicated branch
   4 Improve tokenizer.
   4 Improve error management.
   4 Improve color management in several CLI fields.
   4 Improve code coverage.
   4 Improve VIM syntax file.
   4 Improve TAP support.
   4 Add tests
   3 xunit report
   3 fix style
   3 Use dependencies instead of factory.
   3 Update atoum.php.dist
   3 Reorganize classes/php.
   3 Remove useless file.
   3 Remove useless call to ->assert.
   3 Remove useless argument.
   3 Remove typo in README.
   3 Remove duplicate line.
   3 Remove bug in runner which break ligt report.
   3 Improve unit test about phar generator.
   3 Improve runner to save score in a file.
   3 Improve report code.
   3 Improve color and prompt management in several CLI fields.
   3 Fix typos.
   3 Fix tests
   3 Fix CS
   3 CS Fix
   3 Apply fixes from StyleCI
   3 Add unit tests.
   3 Add plan field for TAP report.
   3 Add coverage.
   3 Add color management in several CLI fields.
   2 writers\std::clear() should not use writers\std\::write().

=> mageekguy: 1780 commit(s)
First commit: Fri May 28 11:55:59 2010 (11 years ago)
Last commit: Tue Feb 24 16:46:59 2015 (6 years ago)
Files changed: 7338
Lines added: 191565
Lines deleted: 105571
Delta: 85994
Add./Del. ratio: 1/0.551098

=> jubianchi: 331 commit(s)
First commit: Mon Sep 12 11:58:42 2011 (9 years ago)
Last commit: Wed Nov 18 21:58:46 2020 (3 months ago)
Files changed: 1498
Lines added: 25883
Lines deleted: 13285
Delta: 12598
Add./Del. ratio: 1/0.513271

=> Ivan Enderlin: 165 commit(s)
First commit: Wed Aug 3 11:51:02 2011 (10 years ago)
Last commit: Wed Nov 18 21:58:46 2020 (3 months ago)
Files changed: 889
Lines added: 86725
Lines deleted: 86212
Delta: 513
Add./Del. ratio: 1/0.994085

=> Frédéric Hardy: 139 commit(s)
First commit: Mon Jun 27 17:51:58 2011 (10 years ago)
Last commit: Tue Sep 29 09:51:30 2020 (5 months ago)
Files changed: 443
Lines added: 13038
Lines deleted: 6861
Delta: 6177
Add./Del. ratio: 1/0.526231

=> Grummfy: 57 commit(s)
First commit: Thu Oct 1 11:52:39 2015 (5 years ago)
Last commit: Thu Jan 14 19:13:00 2021 (4 weeks ago)
Files changed: 701
Lines added: 4023
Lines deleted: 3269
Delta: 754
Add./Del. ratio: 1/0.812578

=> fdussert: 57 commit(s)
First commit: Wed Dec 15 11:01:14 2010 (10 years ago)
Last commit: Tue May 17 00:46:43 2011 (10 years ago)
Files changed: 205
Lines added: 5611
Lines deleted: 2736
Delta: 2875
Add./Del. ratio: 1/0.487614

=> Julien Bianchi: 39 commit(s)
First commit: Fri Feb 3 11:39:41 2012 (9 years ago)
Last commit: Tue Jul 22 11:58:32 2014 (7 years ago)
Files changed: 109
Lines added: 2235
Lines deleted: 1011
Delta: 1224
Add./Del. ratio: 1/0.452349

=> Mikael Randy: 38 commit(s)
First commit: Fri Feb 13 11:17:05 2015 (6 years ago)
Last commit: Mon Apr 9 17:05:48 2018 (2 years, 10 months ago)
Files changed: 62
Lines added: 250
Lines deleted: 103
Delta: 147
Add./Del. ratio: 1/0.412

=> Frédéric Hardy: 22 commit(s)
First commit: 
Last commit: 
Files changed: 443
Lines added: 13038
Lines deleted: 6861
Delta: 6177
Add./Del. ratio: 1/0.526231

=> marmotz: 18 commit(s)
First commit: Tue Sep 25 10:32:26 2012 (8 years ago)
Last commit: Sun Mar 30 12:09:53 2014 (7 years ago)
Files changed: 51
Lines added: 866
Lines deleted: 139
Delta: 727
Add./Del. ratio: 1/0.160508

=> gerald croes: 18 commit(s)
First commit: Wed Nov 30 21:29:21 2011 (9 years ago)
Last commit: Tue Jan 31 14:18:57 2012 (9 years ago)
Files changed: 48
Lines added: 3864
Lines deleted: 742
Delta: 3122
Add./Del. ratio: 1/0.192029

=> Cédric Anne: 17 commit(s)
First commit: Tue Jun 11 11:10:09 2019 (1 year, 8 months ago)
Last commit: Tue Jan 5 10:19:53 2021 (6 weeks ago)
Files changed: 74
Lines added: 1695
Lines deleted: 3138
Delta: -1443
Add./Del. ratio: 1/1.85133

=> Adrien Gallou: 10 commit(s)
First commit: Thu Sep 22 23:01:52 2011 (9 years ago)
Last commit: Mon Feb 20 13:10:44 2017 (4 years ago)
Files changed: 22
Lines added: 1178
Lines deleted: 27
Delta: 1151
Add./Del. ratio: 1/0.0229202

=> Julien BIANCHI: 10 commit(s)
First commit: Fri Feb 3 11:01:42 2012 (9 years ago)
Last commit: Mon Nov 6 16:51:24 2017 (3 years, 3 months ago)
Files changed: 112
Lines added: 848
Lines deleted: 1039
Delta: -191
Add./Del. ratio: 1/1.22524

=> Sylvain Robez-Masson: 10 commit(s)
First commit: Thu Jul 7 11:48:57 2016 (4 years, 7 months ago)
Last commit: Tue Sep 20 21:33:46 2016 (4 years, 5 months ago)
Files changed: 14
Lines added: 232
Lines deleted: 23
Delta: 209
Add./Del. ratio: 1/0.0991379

=> Stéphane PY: 9 commit(s)
First commit: 
Last commit: 
Files changed: 
Lines added: 
Lines deleted: 
Delta: 
Add./Del. ratio: 1/

=> François Dussert: 9 commit(s)
First commit: Tue Aug 2 17:14:15 2011 (10 years ago)
Last commit: Mon Jul 9 14:29:31 2012 (9 years ago)
Files changed: 38
Lines added: 1852
Lines deleted: 107
Delta: 1745
Add./Del. ratio: 1/0.0577754

=> julien.bianchi: 8 commit(s)
First commit: Tue Jul 9 12:42:41 2013 (8 years ago)
Last commit: Thu Nov 19 00:15:54 2020 (3 months ago)
Files changed: 185
Lines added: 4386
Lines deleted: 1293
Delta: 3093
Add./Del. ratio: 1/0.294802

=> Ludovic Fleury: 8 commit(s)
First commit: Fri Apr 6 12:58:42 2012 (9 years ago)
Last commit: Fri Aug 16 13:30:12 2013 (8 years ago)
Files changed: 354
Lines added: 612
Lines deleted: 1266
Delta: -654
Add./Del. ratio: 1/2.06863

=> Remi Collet: 8 commit(s)
First commit: Thu Aug 27 10:53:43 2015 (5 years ago)
Last commit: Fri Jun 21 16:01:28 2019 (1 year, 8 months ago)
Files changed: 12
Lines added: 73
Lines deleted: 17
Delta: 56
Add./Del. ratio: 1/0.232877

=> Jeremy Poulain: 7 commit(s)
First commit: Tue Sep 27 22:43:37 2011 (9 years ago)
Last commit: Wed Jun 11 22:09:11 2014 (7 years ago)
Files changed: 30
Lines added: 2216
Lines deleted: 1939
Delta: 277
Add./Del. ratio: 1/0.875

=> Julien SALLEYRON: 7 commit(s)
First commit: Thu Apr 25 10:17:16 2013 (8 years ago)
Last commit: Tue Dec 17 13:51:27 2013 (7 years ago)
Files changed: 11
Lines added: 437
Lines deleted: 355
Delta: 82
Add./Del. ratio: 1/0.812357

=> Matt Butcher: 7 commit(s)
First commit: Tue Dec 20 19:46:21 2011 (9 years ago)
Last commit: Tue Dec 20 23:34:04 2011 (9 years ago)
Files changed: 8
Lines added: 18
Lines deleted: 13
Delta: 5
Add./Del. ratio: 1/0.722222

=> Johan Cwiklinski: 6 commit(s)
First commit: Mon Jul 10 23:23:52 2017 (3 years, 7 months ago)
Last commit: Fri Oct 4 09:16:30 2019 (1 year, 4 months ago)
Files changed: 31
Lines added: 64
Lines deleted: 59
Delta: 5
Add./Del. ratio: 1/0.921875

=> Chad Burrus: 6 commit(s)
First commit: Tue Aug 30 18:02:24 2011 (9 years ago)
Last commit: Tue Aug 30 18:14:14 2011 (9 years ago)
Files changed: 6
Lines added: 7
Lines deleted: 7
Delta: 0
Add./Del. ratio: 1/1

=> Guillaume Dievart: 6 commit(s)
First commit: Tue Jul 7 22:48:53 2015 (6 years ago)
Last commit: Wed Jan 27 09:40:15 2016 (5 years ago)
Files changed: 10
Lines added: 1799
Lines deleted: 730
Delta: 1069
Add./Del. ratio: 1/0.405781

=> Adrien SAMSON: 5 commit(s)
First commit: Mon Apr 29 12:04:08 2013 (8 years ago)
Last commit: Tue Apr 30 09:54:44 2013 (8 years ago)
Files changed: 5
Lines added: 122
Lines deleted: 15
Delta: 107
Add./Del. ratio: 1/0.122951

=> CedCannes: 5 commit(s)
First commit: Fri Sep 11 09:47:23 2015 (5 years ago)
Last commit: Thu Mar 17 16:16:52 2016 (4 years, 11 months ago)
Files changed: 5
Lines added: 18
Lines deleted: 7
Delta: 11
Add./Del. ratio: 1/0.388889

=> Renaud LITTOLFF: 3 commit(s)
First commit: Fri Apr 26 18:15:43 2013 (8 years ago)
Last commit: Wed Aug 14 17:43:10 2013 (8 years ago)
Files changed: 11
Lines added: 456
Lines deleted: 1
Delta: 455
Add./Del. ratio: 1/0.00219298

=> Simon Jodet: 3 commit(s)
First commit: Mon Jun 11 16:09:26 2012 (9 years ago)
Last commit: Fri Jun 22 15:34:43 2012 (9 years ago)
Files changed: 5
Lines added: 76
Lines deleted: 37
Delta: 39
Add./Del. ratio: 1/0.486842

=> Guislain Duthieuw: 3 commit(s)
First commit: Sun Apr 23 09:27:18 2017 (3 years, 10 months ago)
Last commit: Mon Jul 10 23:50:35 2017 (3 years, 7 months ago)
Files changed: 10
Lines added: 41
Lines deleted: 11
Delta: 30
Add./Del. ratio: 1/0.268293

=> Alexis von Glasow: 3 commit(s)
First commit: Thu Jan 10 11:37:20 2013 (8 years ago)
Last commit: Sat Oct 8 13:09:47 2016 (4 years, 4 months ago)
Files changed: 20
Lines added: 100
Lines deleted: 38
Delta: 62
Add./Del. ratio: 1/0.38

=> Jérémy Romey: 3 commit(s)
First commit: Wed Oct 17 17:39:17 2012 (8 years ago)
Last commit: Tue May 28 11:47:04 2013 (8 years ago)
Files changed: 7
Lines added: 145
Lines deleted: 1
Delta: 144
Add./Del. ratio: 1/0.00689655

=> stealth35: 2 commit(s)
First commit: Mon May 14 13:40:15 2012 (9 years ago)
Last commit: Wed Jun 13 16:07:14 2012 (9 years ago)
Files changed: 2
Lines added: 15
Lines deleted: 1
Delta: 14
Add./Del. ratio: 1/0.0666667

=> Antares Tupin: 2 commit(s)
First commit: Sat Oct 8 21:51:08 2016 (4 years, 4 months ago)
Last commit: Sun Oct 9 13:23:53 2016 (4 years, 4 months ago)
Files changed: 7
Lines added: 60
Lines deleted: 73
Delta: -13
Add./Del. ratio: 1/1.21667

=> Gauthier Delamarre: 2 commit(s)
First commit: Wed Dec 5 19:03:06 2012 (8 years ago)
Last commit: Sat Oct 12 11:15:37 2013 (7 years ago)
Files changed: 4
Lines added: 11
Lines deleted: 6
Delta: 5
Add./Del. ratio: 1/0.545455

=> Gérald Croës: 2 commit(s)
First commit: Sun Dec 11 10:13:33 2011 (9 years ago)
Last commit: Tue Dec 13 11:57:02 2011 (9 years ago)
Files changed: 2
Lines added: 2
Lines deleted: 2
Delta: 0
Add./Del. ratio: 1/1

=> Jean-Baptiste NAHAN: 2 commit(s)
First commit: Thu Mar 8 23:13:58 2018 (2 years, 11 months ago)
Last commit: Sat Mar 10 23:18:11 2018 (2 years, 11 months ago)
Files changed: 2
Lines added: 10
Lines deleted: 0
Delta: 10
Add./Del. ratio: 1/0

=> Julien VINAI: 2 commit(s)
First commit: Tue Dec 4 10:09:35 2012 (8 years ago)
Last commit: Tue Dec 4 13:34:26 2012 (8 years ago)
Files changed: 2
Lines added: 2
Lines deleted: 0
Delta: 2
Add./Del. ratio: 1/0

=> JulienS: 2 commit(s)
First commit: Wed Dec 7 11:55:23 2011 (9 years ago)
Last commit: Wed Dec 7 11:57:02 2011 (9 years ago)
Files changed: 2
Lines added: 2
Lines deleted: 25
Delta: -23
Add./Del. ratio: 1/12.5

=> Jérémy Jourdin: 2 commit(s)
First commit: Fri Nov 7 11:26:57 2014 (6 years ago)
Last commit: Wed Nov 12 13:16:25 2014 (6 years ago)
Files changed: 3
Lines added: 82
Lines deleted: 4
Delta: 78
Add./Del. ratio: 1/0.0487805

=> Mikael RANDY: 2 commit(s)
First commit: Fri Jan 2 23:33:27 2015 (6 years ago)
Last commit: Mon Dec 7 12:42:58 2015 (5 years ago)
Files changed: 2
Lines added: 3
Lines deleted: 2
Delta: 1
Add./Del. ratio: 1/0.666667

=> Nicolas Couet: 2 commit(s)
First commit: Wed Jul 8 11:36:22 2015 (6 years ago)
Last commit: Tue Jul 21 17:44:24 2015 (6 years ago)
Files changed: 2
Lines added: 7
Lines deleted: 1
Delta: 6
Add./Del. ratio: 1/0.142857

=> Scrutinizer Auto-Fixer: 2 commit(s)
First commit: Tue Apr 7 18:03:03 2015 (6 years ago)
Last commit: Thu Apr 9 15:24:03 2015 (6 years ago)
Files changed: 26
Lines added: 51
Lines deleted: 51
Delta: 0
Add./Del. ratio: 1/1

=> fvilpoix: 2 commit(s)
First commit: Sat Sep 30 00:04:24 2017 (3 years, 5 months ago)
Last commit: Sat Sep 30 00:04:24 2017 (3 years, 5 months ago)
Files changed: 6
Lines added: 33
Lines deleted: 4
Delta: 29
Add./Del. ratio: 1/0.121212

=> gbouchez: 2 commit(s)
First commit: Mon Jul 10 22:18:23 2017 (3 years, 7 months ago)
Last commit: Wed Aug 30 22:21:11 2017 (3 years, 6 months ago)
Files changed: 3
Lines added: 6
Lines deleted: 0
Delta: 6
Add./Del. ratio: 1/0

=> srm: 2 commit(s)
First commit: Mon Jul 11 22:45:59 2016 (4 years, 7 months ago)
Last commit: Thu Jul 14 10:48:48 2016 (4 years, 7 months ago)
Files changed: 4
Lines added: 30
Lines deleted: 14
Delta: 16
Add./Del. ratio: 1/0.466667

=> Ilya Detinkin: 1 commit(s)
First commit: Wed Oct 21 15:40:00 2020 (4 months ago)
Last commit: Wed Oct 21 15:40:00 2020 (4 months ago)
Files changed: 1
Lines added: 4
Lines deleted: 4
Delta: 0
Add./Del. ratio: 1/1

=> Miha Vrhovnik: 1 commit(s)
First commit: Fri Dec 30 22:00:14 2016 (4 years, 1 month ago)
Last commit: Fri Dec 30 22:00:14 2016 (4 years, 1 month ago)
Files changed: 1
Lines added: 3
Lines deleted: 0
Delta: 3
Add./Del. ratio: 1/0

=> Andrey Pashentsev: 1 commit(s)
First commit: Sun Oct 9 10:55:31 2016 (4 years, 4 months ago)
Last commit: Sun Oct 9 10:55:31 2016 (4 years, 4 months ago)
Files changed: 4
Lines added: 9
Lines deleted: 23
Delta: -14
Add./Del. ratio: 1/2.55556

=> HornWilly: 1 commit(s)
First commit: Tue Jul 23 15:59:31 2013 (8 years ago)
Last commit: Tue Jul 23 15:59:31 2013 (8 years ago)
Files changed: 1
Lines added: 10
Lines deleted: 2
Delta: 8
Add./Del. ratio: 1/0.2

=> Nelson da Costa: 1 commit(s)
First commit: Wed Jul 10 23:24:43 2013 (8 years ago)
Last commit: Wed Jul 10 23:24:43 2013 (8 years ago)
Files changed: 1
Lines added: 2
Lines deleted: 2
Delta: 0
Add./Del. ratio: 1/1

=> Adrien Carbonne: 1 commit(s)
First commit: Thu Jul 7 22:16:40 2011 (10 years ago)
Last commit: Thu Jul 7 22:16:40 2011 (10 years ago)
Files changed: 3
Lines added: 78
Lines deleted: 33
Delta: 45
Add./Del. ratio: 1/0.423077

=> Nissar Chababy: 1 commit(s)
First commit: Wed Feb 22 16:10:54 2017 (4 years ago)
Last commit: Wed Feb 22 16:10:54 2017 (4 years ago)
Files changed: 1
Lines added: 60
Lines deleted: 60
Delta: 0
Add./Del. ratio: 1/1

=> Noé De Cuyper: 1 commit(s)
First commit: Mon Sep 26 11:36:29 2016 (4 years, 5 months ago)
Last commit: Mon Sep 26 11:36:29 2016 (4 years, 5 months ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> Oliver THEBAULT: 1 commit(s)
First commit: Wed Feb 10 22:35:10 2016 (5 years ago)
Last commit: Wed Feb 10 22:35:10 2016 (5 years ago)
Files changed: 1
Lines added: 3
Lines deleted: 3
Delta: 0
Add./Del. ratio: 1/1

=> Olivier Balais: 1 commit(s)
First commit: Fri Nov 18 11:37:55 2011 (9 years ago)
Last commit: Fri Nov 18 11:37:55 2011 (9 years ago)
Files changed: 1
Lines added: 6
Lines deleted: 6
Delta: 0
Add./Del. ratio: 1/1

=> Pierre Merlin: 1 commit(s)
First commit: Sun Nov 30 15:12:23 2014 (6 years ago)
Last commit: Sun Nov 30 15:12:23 2014 (6 years ago)
Files changed: 1
Lines added: 9
Lines deleted: 0
Delta: 9
Add./Del. ratio: 1/0

=> Guillaume Paton: 1 commit(s)
First commit: Thu Aug 27 11:56:31 2015 (5 years ago)
Last commit: Thu Aug 27 11:56:31 2015 (5 years ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> Gilles Crettenand: 1 commit(s)
First commit: Sat Feb 11 14:17:52 2017 (4 years ago)
Last commit: Sat Feb 11 14:17:52 2017 (4 years ago)
Files changed: 2
Lines added: 29
Lines deleted: 0
Delta: 29
Add./Del. ratio: 1/0

=> Rodrigue Villetard: 1 commit(s)
First commit: Wed Jul 3 15:51:21 2013 (8 years ago)
Last commit: Wed Jul 3 15:51:21 2013 (8 years ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> Romain Pouclet: 1 commit(s)
First commit: Tue Aug 9 17:16:15 2011 (10 years ago)
Last commit: Tue Aug 9 17:16:15 2011 (10 years ago)
Files changed: 2
Lines added: 65
Lines deleted: 0
Delta: 65
Add./Del. ratio: 1/0

=> menthol: 1 commit(s)
First commit: Sat Mar 3 01:37:04 2012 (9 years ago)
Last commit: Sat Mar 3 01:37:04 2012 (9 years ago)
Files changed: 1
Lines added: 28
Lines deleted: 0
Delta: 28
Add./Del. ratio: 1/0

=> Geoffrey Bachelet: 1 commit(s)
First commit: Tue Feb 14 22:59:20 2012 (9 years ago)
Last commit: Tue Feb 14 22:59:20 2012 (9 years ago)
Files changed: 1
Lines added: 2
Lines deleted: 1
Delta: 1
Add./Del. ratio: 1/0.5

=> Spencer Rinehart: 1 commit(s)
First commit: Tue Jul 1 01:05:38 2014 (7 years ago)
Last commit: Tue Jul 1 01:05:38 2014 (7 years ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> Florian Ferriere: 1 commit(s)
First commit: Mon Mar 21 15:40:00 2016 (4 years, 11 months ago)
Last commit: Mon Mar 21 15:40:00 2016 (4 years, 11 months ago)
Files changed: 2
Lines added: 21
Lines deleted: 13
Delta: 8
Add./Del. ratio: 1/0.619048

=> Florent Lavy: 1 commit(s)
First commit: Mon Oct 17 17:26:13 2011 (9 years ago)
Last commit: Mon Oct 17 17:26:13 2011 (9 years ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> Thibault Pierre: 1 commit(s)
First commit: Tue Apr 16 21:06:51 2019 (1 year, 10 months ago)
Last commit: Tue Apr 16 21:06:51 2019 (1 year, 10 months ago)
Files changed: 1
Lines added: 1
Lines deleted: 0
Delta: 1
Add./Del. ratio: 1/0

=> Thomas Tourlourat: 1 commit(s)
First commit: Fri Dec 7 15:37:42 2012 (8 years ago)
Last commit: Fri Dec 7 15:37:42 2012 (8 years ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> Xavier Mouton-Dubosc: 1 commit(s)
First commit: Mon Jul 14 17:13:34 2014 (7 years ago)
Last commit: Mon Jul 14 17:13:34 2014 (7 years ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> adrien: 1 commit(s)
First commit: Thu Jul 7 01:13:13 2011 (10 years ago)
Last commit: Thu Jul 7 01:13:13 2011 (10 years ago)
Files changed: 59
Lines added: 2644
Lines deleted: 101
Delta: 2543
Add./Del. ratio: 1/0.0381997

=> adrienc: 1 commit(s)
First commit: Wed Jun 22 01:51:52 2011 (10 years ago)
Last commit: Wed Jun 22 01:51:52 2011 (10 years ago)
Files changed: 21
Lines added: 996
Lines deleted: 34
Delta: 962
Add./Del. ratio: 1/0.0341365

=> Evert Pot: 1 commit(s)
First commit: Wed Dec 17 15:42:01 2014 (6 years ago)
Last commit: Wed Dec 17 15:42:01 2014 (6 years ago)
Files changed: 1
Lines added: 2
Lines deleted: 2
Delta: 0
Add./Del. ratio: 1/1

=> ronan: 1 commit(s)
First commit: Wed Nov 14 14:45:13 2012 (8 years ago)
Last commit: Wed Nov 14 14:45:13 2012 (8 years ago)
Files changed: 2
Lines added: 153
Lines deleted: 0
Delta: 153
Add./Del. ratio: 1/0

=> Adirelle: 1 commit(s)
First commit: Thu Sep 12 18:14:59 2013 (7 years ago)
Last commit: Thu Sep 12 18:14:59 2013 (7 years ago)
Files changed: 2
Lines added: 36
Lines deleted: 32
Delta: 4
Add./Del. ratio: 1/0.888889

=> Denis Roussel: 1 commit(s)
First commit: Mon Apr 22 15:58:53 2013 (8 years ago)
Last commit: Mon Apr 22 15:58:53 2013 (8 years ago)
Files changed: 1
Lines added: 4
Lines deleted: 1
Delta: 3
Add./Del. ratio: 1/0.25

=> Julien Tardot: 1 commit(s)
First commit: Sat Aug 10 20:34:58 2013 (8 years ago)
Last commit: Sat Aug 10 20:34:58 2013 (8 years ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> guiled: 1 commit(s)
First commit: Mon Oct 2 15:35:15 2017 (3 years, 4 months ago)
Last commit: Mon Oct 2 15:35:15 2017 (3 years, 4 months ago)
Files changed: 1
Lines added: 2
Lines deleted: 2
Delta: 0
Add./Del. ratio: 1/1

=> Damien Seguy: 1 commit(s)
First commit: Thu Jan 15 14:38:53 2015 (6 years ago)
Last commit: Thu Jan 15 14:38:53 2015 (6 years ago)
Files changed: 4
Lines added: 5
Lines deleted: 5
Delta: 0
Add./Del. ratio: 1/1

=> Julius Beckmann: 1 commit(s)
First commit: Thu Apr 24 15:53:54 2014 (7 years ago)
Last commit: Thu Apr 24 15:53:54 2014 (7 years ago)
Files changed: 1
Lines added: 4
Lines deleted: 0
Delta: 4
Add./Del. ratio: 1/0

=> Croës: 1 commit(s)
First commit: Fri Jul 29 15:14:28 2011 (10 years ago)
Last commit: Fri Jul 29 15:14:28 2011 (10 years ago)
Files changed: 3
Lines added: 3
Lines deleted: 3
Delta: 0
Add./Del. ratio: 1/1

=> James Fuller: 1 commit(s)
First commit: Wed Apr 15 18:09:21 2015 (6 years ago)
Last commit: Wed Apr 15 18:09:21 2015 (6 years ago)
Files changed: 1
Lines added: 1
Lines deleted: 1
Delta: 0
Add./Del. ratio: 1/1

=> Kao ..98: 1 commit(s)
First commit: Mon Dec 7 21:52:54 2015 (5 years ago)
Last commit: Mon Dec 7 21:52:54 2015 (5 years ago)
Files changed: 
Lines added: 
Lines deleted: 
Delta: 
Add./Del. ratio: 1/

=> JTA: 1 commit(s)
First commit: Mon Aug 12 11:02:03 2013 (8 years ago)
Last commit: Mon Aug 12 11:02:03 2013 (8 years ago)
Files changed: 1
Lines added: 2
Lines deleted: 0
Delta: 2
Add./Del. ratio: 1/0

=> Metalaka: 1 commit(s)
First commit: Sat Jul 4 00:56:38 2015 (6 years ago)
Last commit: Sat Jul 4 00:56:38 2015 (6 years ago)
Files changed: 2
Lines added: 8
Lines deleted: 0
Delta: 8
Add./Del. ratio: 1/0

==> IP adresses and ports:
=> IPs: 0

=> Ports: 0
==> Commits by author:
     1780 |█████████████████████████████████████████████████ mageekguy
      331 |█████████ jubianchi
      165 |████ Ivan Enderlin
      139 |███ Frédéric Hardy
       57 |█ fdussert
       57 |█ Grummfy
       39 |█ Julien Bianchi
       38 |█ Mikael Randy
       22 | Frédéric Hardy
       18 | marmotz
       18 | gerald croes
       17 | Cédric Anne
       10 | Sylvain Robez-Masson
       10 | Julien BIANCHI
       10 | Adrien Gallou
        9 | Stéphane PY
        9 | François Dussert
        8 | julien.bianchi
        8 | Remi Collet
        8 | Ludovic Fleury
        7 | Matt Butcher
        7 | Julien SALLEYRON
        7 | Jeremy Poulain
        6 | Johan Cwiklinski
        6 | Guillaume Dievart
        6 | Chad Burrus
        5 | CedCannes
        5 | Adrien SAMSON
        3 | Simon Jodet
        3 | Renaud LITTOLFF
        3 | Jérémy Romey
        3 | Guislain Duthieuw
        3 | Alexis von Glasow
        2 | stealth35
        2 | srm
        2 | gbouchez
        2 | fvilpoix
        2 | Scrutinizer Auto-Fixer
        2 | Nicolas Couet
        2 | Mikael RANDY
        2 | JulienS
        2 | Julien VINAI
        2 | Jérémy Jourdin
        2 | Jean-Baptiste NAHAN
        2 | Gérald Croës
        2 | Gauthier Delamarre
        2 | Antares Tupin
        1 | ronan
        1 | menthol
        1 | guiled
        1 | adrienc
        1 | adrien
        1 | Xavier Mouton-Dubosc
        1 | Thomas Tourlourat
        1 | Thibault Pierre
        1 | Spencer Rinehart
        1 | Romain Pouclet
        1 | Rodrigue Villetard
        1 | Pierre Merlin
        1 | Olivier Balais
        1 | Oliver THEBAULT
        1 | Noé De Cuyper
        1 | Nissar Chababy
        1 | Nelson da Costa
        1 | Miha Vrhovnik
        1 | Metalaka
        1 | Kao ..98
        1 | Julius Beckmann
        1 | Julien Tardot
        1 | James Fuller
        1 | JTA
        1 | Ilya Detinkin
        1 | HornWilly
        1 | Guillaume Paton
        1 | Gilles Crettenand
        1 | Geoffrey Bachelet
        1 | Florian Ferriere
        1 | Florent Lavy
        1 | Evert Pot
        1 | Denis Roussel
        1 | Damien Seguy
        1 | Croës
        1 | Andrey Pashentsev
        1 | Adrien Carbonne
        1 | Adirelle

==> Commits by month:
	Jan	211	|█████
	Feb	187	|█████
	Mar	275	|███████
	Apr	259	|███████
	May	163	|████
	Jun	222	|██████
	Jul	232	|██████
	Aug	181	|█████
	Sep	251	|███████
	Oct	308	|████████
	Nov	266	|███████
	Dec	259	|███████

==> Commits by day:
	Mon	473	|█████████████
	Tue	573	|████████████████
	Wed	561	|███████████████
	Thu	452	|████████████
	Fri	499	|██████████████
	Sat	132	|███
	Sun	124	|███

==> Commits by hour:
	00	47	|█
	01	10	|
	02	4	|
	03	0	|
	04	1	|
	05	2	|
	06	14	|
	07	21	|
	08	40	|█
	09	124	|███
	10	184	|█████
	11	226	|██████
	12	241	|██████
	13	412	|███████████
	14	254	|███████
	15	230	|██████
	16	192	|█████
	17	165	|████
	18	85	|██
	19	44	|█
	20	65	|█
	21	147	|████
	22	195	|█████
	23	111	|███
```
