# Contributing and testing

Note: This file is a work in progress.

## Non-Regression tests & Code Cleanup

```bash
# Code Cleanup
pre-commit run --all-files
# Ensure no regression is pushed
bypass-url-parser -S 0 -v -u http://127.0.0.1:8000/foo/bar --dump-payloads > "tests-history/bup-payloads-$(date +'%Y-%m-%d').lst"
# Compare /tmp/bup-payloads-YYYY-MM-DD.lst and the latest tests-history/bup-payloads-YYYY-MM-DD.lst
git diff --no-index $(find tests-history -type f | sort -n | tail -n 2)
# Push your changes
git add .
git commit -m "My cool feature or bugfix"
git tag -a vX.Y.Z "$COMMIT_HASH" -m "New release: vX.Y.Z"
git push --tags
# If X or Y is bumped, create new release on github
```

## Github Action Release

- Visit https://github.com/laluka/bypass-url-parser/actions/workflows/release.yml
- Run Workflow with a version such as `0.4.1` or `0.4.1.a` for alpha tests
- Test the alpha version with the below script, once done, repeat without `.a`

```bash
cd /tmp
export TESTED_VERSION=0.4.1a
pipx install "bypass-url-parser==$TESTED_VERSION"
bup --version && bup -u https://thinkloveshare.com/ -t 50 -m http_headers_scheme
pipx uninstall bypass-url-parser
bup --version # Should fail

pip install "bypass-url-parser==$TESTED_VERSION"
bup --version && bup -u https://thinkloveshare.com/ -t 50 -m http_headers_scheme
pip uninstall bypass-url-parser
bup --version # Should fail

for version in {8..13}; do
  docker run --rm -it "python:3.$version" bash -c "pip install bypass-url-parser==$TESTED_VERSION && bup --version && bup -u https://thinkloveshare.com/ -t 50 -m http_headers_scheme"
done
```

## To test that all supported versions can build and boot

```bash
for version in {8..13}; do
  docker run --rm -it -v "$PWD":/host -w /host "python:3.$version" bash -c 'git config --global --add safe.directory /host && PDM_BUILD_SCM_VERSION="$(git describe --abbrev=0)-dev" pip install . && bup -u https://thinkloveshare.com/ -t 50 -m http_headers_scheme'
done
```
