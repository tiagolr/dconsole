:: Creates coverage report and saves it to report.txt file.
:: MCoverage lib must be installed
@echo off
CALL lime test neko -debug -DCOVERAGE > report.txt