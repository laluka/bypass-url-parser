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
import json
import logging
import os
import re
import sys
import tempfile
import urllib

VERSION = "0.1.0"
logger = logging.getLogger("bup")
config = dict()


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
