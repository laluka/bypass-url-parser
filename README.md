# Bypass Url Parser

Tool that tests `MANY` url bypasses to reach a `40X protected page`.


## Setup for bypass.py

```bash
virtualenv -p python3 .py3
source .py3/bin/activate
pip install -r requirements.txt
./bypass-url-parser.py http://127.0.0.1/juicy_403_endpoint/
```


## Usage

```
Bypass Url Parser, made with love by @TheLaluka
A tool that tests MANY url bypasses to reach a 40X protected page.

Usage:
    ./bypass-url-parser.py --url=<URL> [--outdir=<OUTDIR>] [--debug]
    ./bypass-url-parser.py (-h | --help)
    ./bypass-url-parser.py (-v | --version)

Options:
    -h --help            Show help, you are here :)
    -v --version         Show version info.
    --url=<URL>          URL (path is optional) to run bypasses against.
    --outdir=<outdir>    Output directory for results.
    --debug              Enable debugging output, to... Tou know... Debug.

Example:
    ./bypass-url-parser.py --url http://127.0.0.1/juicy_403_endpoint/
```


## Expected result

```
TODO: add sample run once it works :)
```
