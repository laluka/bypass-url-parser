import logging
from unittest.mock import Mock
from urllib.parse import urlparse

import pytest

from bypass_url_parser import Bypasser, CurlItem


def make_curl_item(raw_response):
    url = urlparse("https://example.com/admin")
    item = CurlItem(
        url,
        ["curl", "--path-as-is"],
        ["curl", "--path-as-is", url.geturl()],
        bypass_mode="original_request",
        ext_logger=logging.getLogger("tests"),
    )
    item.response_raw_output = raw_response
    return item


@pytest.mark.parametrize(
    "header_value",
    [
        "application/problem+json",
        "application/vnd.api+json; charset=utf-8",
        'multipart/form-data; boundary="example-boundary"',
        "image/svg+xml",
    ],
)
def test_response_content_type_accepts_rfc_token_characters_and_parameters(header_value):
    item = make_curl_item(f"HTTP/1.1 200 OK\ncontent-type:{header_value}\n\nbody")

    assert item.response_content_type == header_value


def test_mid_paths_preserve_query_separator(monkeypatch):
    target = urlparse("https://example.com/path1/test2/secretendpoint?a=test")
    bypasser = Bypasser.__new__(Bypasser)
    bypasser.verbose = False
    bypasser.dump_payloads = False
    bypasser.logger = Mock()
    bypasser.base_curl = ["curl", "--path-as-is"]
    bypasser.curl_items = set()
    bypasser._current_bypass_modes = {"mid_paths"}
    bypasser.internal_midpaths = ["..;"]
    bypasser.encoding = "UTF-8"
    bypasser.debug = False

    monkeypatch.setattr("socket.gethostbyname", lambda _hostname: "192.0.2.1")
    bypasser._generate_curls(target)

    generated_urls = [
        item.request_curl_cmd[-1]
        for item in bypasser.curl_items
        if item.bypass_mode == "mid_paths"
    ]
    assert generated_urls
    assert all(urlparse(url).query == "a=test" for url in generated_urls)
    assert all("endpointa=test" not in url for url in generated_urls)
