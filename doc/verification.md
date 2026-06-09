# Steps for running verification

![Verification Environment](output/verification.png)

* git clone git@github.com:openhwgroup/core-et-erbium.git
* cd hdl-et/
* make -C tb setup
* uv sync
* source .venv/bin/activate
* make <MODULE=testname>

