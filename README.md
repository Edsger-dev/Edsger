# Edsger

Compute equilibrium flows on traffic networks.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![CircleCI](https://circleci.com/gh/Edsger-dev/Edsger/tree/master.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/Edsger-dev/Edsger/tree/master) [![codecov](https://codecov.io/gh/Edsger-dev/Edsger/branch/master/graph/badge.svg)](https://codecov.io/gh/Edsger-dev/Edsger)

Edsger has been developed in python 3.7.  

## Linux install

### Standard install

```bash
git clone git@github.com:Edsger-dev/Edsger.git edsger_dir/
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