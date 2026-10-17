# Contributing and testing

## Non-regression tests and code cleanup

```bash
# Code cleanup
pre-commit run --all-files
# Run the test matrix and linter
pdm run tox run-parallel
pdm run lint-ruff
# Ensure no regression is pushed
bypass-url-parser -S 0 -v -u http://127.0.0.1:8000/foo/bar --dump-payloads > "tests-history/bup-payloads-$(date +'%Y-%m-%d').lst"
# Or run directly from source
python src/bypass_url_parser/__init__.py -S 0 -v -u http://127.0.0.1:8000/foo/bar --dump-payloads > "tests-history/bup-payloads-$(date +'%Y-%m-%d').lst"
# Compare the two latest payload snapshots
git diff --no-index $(find tests-history -type f | sort | tail -n 2)
# Push your changes
git add .
git commit -m "My cool feature or bugfix"
```

## GitHub Actions release

The release workflow builds the wheel and source distribution, creates and pushes the Git tag, publishes to PyPI,
publishes the container to GHCR, and creates a draft GitHub release with generated notes. Do not create the tag
manually.

Use a [PEP 440](https://peps.python.org/pep-0440/) version without a leading `v`, such as `0.4.5` for a stable release
or `0.4.5a1` for an alpha.

### 1. Confirm the release commit

```bash
git switch main
git pull --ff-only
git status --short
git log -1 --oneline
RELEASE_SHA="$(git rev-parse HEAD)"
```

The worktree should be clean, and the latest `main` CI run should be green.

### 2. Run a safe build-only dry run

Leave the `tag` input empty. The workflow validates the commit and builds the distributions without creating a tag or
publishing anything.

```bash
gh workflow run release.yml --ref main -f sha="$RELEASE_SHA"
```

You can also use **Actions → Release PyPI, Docker and GitHub → Run workflow** in the GitHub UI.

### 3. Publish the release

Publishing is immediate and uploads immutable artifacts to PyPI. Verify the version and commit before running:

```bash
RELEASE_VERSION="0.4.5"
gh workflow run release.yml --ref main -f tag="$RELEASE_VERSION" -f sha="$RELEASE_SHA"
```

Monitor the run in GitHub Actions. Once it succeeds, review the generated draft on the GitHub Releases page and publish
the draft.

### 4. Smoke-test the published artifacts

```bash
TESTED_VERSION="0.4.5"
python -m venv /tmp/bup-release-test
source /tmp/bup-release-test/bin/activate
pip install "bypass-url-parser==$TESTED_VERSION"
bup --version && bup -u https://thinkloveshare.com/ -t 50 -m http_headers_scheme
pip uninstall bypass-url-parser
bup --version # This should fail

pipx install -f "bypass-url-parser==$TESTED_VERSION"
bup --version && bup -u https://thinkloveshare.com/ -t 50 -m http_headers_scheme
pipx uninstall bypass-url-parser
bup --version # This should fail

for version in {8..13}; do
  docker run --rm -it "python:3.$version" bash -c \
    "pip install bypass-url-parser==$TESTED_VERSION && bup --version"
done

docker run --rm "ghcr.io/laluka/bypass-url-parser:$TESTED_VERSION" --version
```

## To test that all supported versions can build and boot

```bash
for version in {8..13}; do
  docker run --rm -it -v "$PWD":/host -w /host "python:3.$version" bash -c 'git config --global --add safe.directory /host && PDM_BUILD_SCM_VERSION="$(git describe --abbrev=0)-dev" pip install . && bup -u https://thinkloveshare.com/ -t 50 -m http_headers_scheme'
done
```
