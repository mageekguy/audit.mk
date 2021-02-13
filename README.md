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

Requirements to use `àudit.mk` are:

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

## Why using GNU Make?

To avoid rebuild of all files used to generate the report on each run.
