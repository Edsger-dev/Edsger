# Edsger

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![CircleCI](https://circleci.com/gh/Edsger-dev/Edsger/tree/master.svg?style=svg)](https://circleci.com/gh/Edsger-dev/Edsger/tree/master)

Edsger has been developed in python 3.7.  

## Linux install

### Standard install

```bash
cd edsger_dir/
edsger_dir $ pip install -r requirements.txt
edsger_dir $ pip install .
```

### Test install

* `bash`

```bash
edsger_dir $ pip install .[test]
```

* `zsh` (ìf you're using `zsh` you need to escape square brackets)

```bash
edsger_dir $ pip install .\[test\]
```
## Run the tests

```bash
cd edsger_dir/
edsger_dir $ pytest
```