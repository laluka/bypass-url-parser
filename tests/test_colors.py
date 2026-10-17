import io
import logging
import sys
from unittest.mock import Mock
from urllib.parse import urlparse

import pytest
from colorama import Fore, Style

from bypass_url_parser import Bypasser, CurlItem, Tools


def make_curl_item(status_code=200):
    url = urlparse("https://example.com/admin")
    item = CurlItem(
        url,
        ["curl", "--path-as-is"],
        ["curl", "--path-as-is", url.geturl()],
        bypass_mode="original_request",
        ext_logger=logging.getLogger("tests"),
    )
    item.response_raw_output = f"HTTP/1.1 {status_code} Status\nContent-Type: text/html\n\nbody"
    return item


@pytest.mark.parametrize(
    ("status_code", "color"),
    [(200, Fore.GREEN), (301, Fore.BLUE), (403, Fore.YELLOW), (500, Fore.RED)],
)
def test_status_code_colors(status_code, color):
    item = make_curl_item(status_code)

    assert f"[{color}{status_code}{Style.RESET_ALL}]" in item.get_formatted_response(with_colors=True)
    assert "\x1b[" not in item.get_formatted_response()


def test_output_colors_are_disabled_for_redirected_stderr(monkeypatch):
    item = make_curl_item()
    bypasser = Bypasser.__new__(Bypasser)
    bypasser.curl_items = {item}
    bypasser.clean_output = ""
    bypasser._urls = [item.target_url]
    bypasser.save_level = Bypasser.SaveLevel.NONE
    bypasser.output_dir = ""
    bypasser.logger = Mock()
    bypasser.verbose = False
    bypasser.jsonl_output = False

    monkeypatch.setattr(sys, "stderr", io.StringIO())
    bypasser._output_results(item.target_url)

    logged_output = bypasser.logger.info.call_args.args[0]
    assert "\x1b[" not in logged_output
    assert "\x1b[" not in bypasser.clean_output


def test_interactive_output_is_colored_but_saved_output_stays_plain(monkeypatch):
    class InteractiveStream(io.StringIO):
        def isatty(self):
            return True

    item = make_curl_item()
    bypasser = Bypasser.__new__(Bypasser)
    bypasser.curl_items = {item}
    bypasser.clean_output = ""
    bypasser._urls = [item.target_url]
    bypasser.save_level = Bypasser.SaveLevel.NONE
    bypasser.output_dir = ""
    bypasser.logger = Mock()
    bypasser.verbose = False
    bypasser.jsonl_output = False

    monkeypatch.delenv("NO_COLOR", raising=False)
    monkeypatch.setattr(sys, "stderr", InteractiveStream())
    bypasser._output_results(item.target_url)

    logged_output = bypasser.logger.info.call_args.args[0]
    assert f"{Fore.GREEN}200{Style.RESET_ALL}" in logged_output
    assert "\x1b[" not in bypasser.clean_output


def test_no_color_environment_variable_disables_colors(monkeypatch):
    monkeypatch.setenv("NO_COLOR", "1")

    assert not Tools.supports_colors(Mock(isatty=Mock(return_value=True)))
