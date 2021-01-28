# A makefile to extract some metrics from a PHP Project

## Features

- Check EOL;
- Check encoding;
- Find largest files (PHP, JS, JSON, CSS, HTML, images, binaries);
- Find duplicated files (PHP, JS, JSON, CSS, HTML, images, binaries);
- Check PHP syntax;
- Check PHP files coding style according to PSR2;
- Find copy/paste code;
- Find commits number, branches, tags, authors, first commit and last commit in a Git repository;
- Find commits number, branches, tags, authors, first commit and last commit for each authors in a Git repository;
- Find duplicated commit messages;
- Search hardcoded IP addresses.

# Requirements

Requirements to use `àudit.mk` are:

- [GNU Make](https://www.gnu.org/software/make/);
- [fdupes](https://github.com/adrianlopezroche/fdupes);
- [git](https://git-scm.com);
- bash.

Moreover, some utility tools like `awk` and `sed` are mandatory.  
And `audit.mk` was develop using OSX, so it must be incompatible with Linux/Windows (but it is POSIX compliant).

# Installation

1. Clone the repository somewhere on your file system;
2. Do `make -f path/to/audit.mk audit` in the folder of your PHP project.

A directory named `.audit` will be created and a report will be displayed after a few moment (the analyze can take long time according to the size of your project).  
The directory contains some interesting files used to generate the report.
Do `make help` for more informations.

# Tips

You can do `make  -f path/to/audit.mk audit WITH_DEBUG=true` to have (lot of) more informations about the audit process.

# FAQ

## Why using GNU Make?

To avoid rebuild of all files used to generate the report on each run.
