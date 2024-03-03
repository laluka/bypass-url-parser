#!/usr/bin/env python3
from __future__ import annotations

from bypass_url_parser import Bypasser

# Init Bypasser (Without external logger. In this case, the library set his own logger)
exporter = Bypasser(verbose=False, debug=False, debug_class=False, ext_logger=None)

# Set object properties (see complete list in Bypasser.__init__())
exporter.threads = 10
exporter.timeout = 3
exporter.current_bypass_modes = (
    "http_methods, http_headers_scheme, case_substitution, char_encode"
)
# exporter.current_bypass_modes = "all"
exporter.save_level = Bypasser.SaveLevel.NONE  # Disable results saving

# Set target(s)
target_urls: list[str] = list()
# target_urls.append("http://thinkloveshare.com/juicy_403_endpoint/")
target_urls.append("http://127.0.0.1:8000/foo")

# Libray only
filter_status_codes = []
# filter_status_codes = [400, 403, 405]

# Run curl commands
bypass_results = exporter.run(urls=target_urls, silent_mode=True)

# Print results like tool output
for url, grouped_items in bypass_results.items():
    print(f"\nBypass results for '{url.geturl()}' url:")
    library_output = Bypasser.get_results_from_grouped_items(url, grouped_items, header_line=True, with_filename=False,
                                                             filter_sc=filter_status_codes)
    print(library_output)

if not exporter.verbose and exporter.save_level != Bypasser.SaveLevel.NONE:
    print(f"\nBypasser results stored in '{exporter.output_dir}' directory")

# do stuff...
