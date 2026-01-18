# scat

A lightweight static code analysis tool written in **AWK** for analyzing C/C++ header files.
The goal of this project is to extract useful structural and documentation-related insights from header files without implementing a full C/C++ parser.

This project is intentionally heuristic-based and Unix-style: fast, simple, and transparent about its limitations.
It is meant to be accurate, but if you find a bug please let me know!

---

## Features

### File Metadata

* File name
* File size (bytes)
* File type detection (based on extension)

### Line Statistics

* Total lines
* Lines of code (LOC)
* Blank lines

### Include Analysis

* System headers (`#include <...>`)
* User headers (`#include "..."`)
* Total include count

### Preprocessor Directive Analysis

* Counts of:

  * `#if`
  * `#ifdef`
  * `#ifndef`
  * `#elif`
  * `#else`
  * `#endif`
* Warning for likely unbalanced conditional directives (e.g., missing `#endif`)

### Comment Analysis

* Single-line comments (`//`)
* Multi-line comments (`/* ... */`)
* Comment density (percentage of comment lines relative to LOC)
* Detection of tagged comments (not counted separately):

  * `TODO`
  * `FIXME`
  * `BUG`
  * `NOTE`

---

## Example Output

```
-----    Metadata    -----
File: header_check.h
Size of file: 177 B
File type: h file

----- Code Analytics -----
Lines Of Code (LOC):  7
Total line(s):  15
Blank line(s):  8

Includes:
 System header(s) included:
 User header(s) included:
 Total include(s):  0

Total ifndef directives:  1
.
.
.
WARNING: Likely missing a #endif

Comments:
 Single-line:  2
 Multi-line:  2
 Comment density:  57.14 %
 TODO comments:  1
```

---

## Usage

```bash
gawk -f header_check.awk header_file.h
```

The script expects a filename as input (not stdin) in order to retrieve file metadata.

---

## Design Philosophy

* **Not a compiler**: This tool does not attempt to fully parse C/C++.
* **Heuristic-based**: Results are best-effort and may include false positives.
* **State-machine driven**: Comment and string handling is implemented using simple state tracking.
* **Unix mindset**: Small, focused, composable. (Does what it specifies)

---

## Limitations

* Does not fully handle escaped quotes inside strings
* Block comments inside strings may lead to inaccuracies
* Nested block comments are not supported (consistent with the C standard)
* Macro expansion is not performed
* Preprocessor conditionals are analyzed structurally, not semantically

---

## Why AWK?

AWK was chosen deliberately to explore:

* Text processing at scale
* State-machine style parsing
* The limits of regex-based analysis

This project serves as a prototype for potential re-implementation in a different language.

---

## Future Work

* Include guard detection summary
* Optional verbose mode for directive tracing
* Rewrite in C or Python for deeper analysis
* Add features to make scat even better in AWK

Built as a learning-focused system tooling project.
---

## License

MIT License

---
