# Vendored: cocotbext-xspi

A COCOTB verification IP for the xSPI / HyperBus protocol (driver, monitor, bus
model). Vendored into this repo so the build has no dependency on a private
repository.

- **Upstream:** `git@github.com:nekkoai/cocotbext-xspi.git`
- **Vendored from commit:** `affc353370cd15f4f0e8273b7e3188f95a5b5a92` (branch `main`)
- **License:** Apache-2.0 (see `LICENSE`)
- **Author:** Vijayvithal Jahagirdar

Only the importable package (`src/cocotbext/xspi/`), `LICENSE`, and `README.md`
were copied; the upstream dev/docs/CI tooling and git-tag-based versioning were
dropped, and the version is pinned statically in `pyproject.toml`.

To update: copy `src/`, `LICENSE`, `README.md` from a newer upstream commit and
record the new commit hash above.
