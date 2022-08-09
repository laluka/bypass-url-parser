from ./bypass-url-parser import Bypasser

# Init Bypasser (Without external logger. In this case, the library set his own logger)
exporter = Bypasser(verbose=True, debug=False, debug_class=False, ext_logger=None)

# Set properties (complete list in Bypasser.__init__())
exporter.threads = 10
exporter.timeout = 3
exporter.current_bypass_modes = "http_methods, http_headers_scheme, case_substitution, char_encode"
exporter.save_level = 0  # Disable results saving

# Set target(s)
urls = list()
urls.append("http://127.0.0.1:8000/admin1/")
urls.append("http://127.0.0.1:8000/admin2/")

# Run curl commands
bypass_results = exporter.run(urls, silent_mode=True)

# Print results like tool output
for url, grouped_items in bypass_results.items():
    print(f"Bypass results for '{url.geturl()}' url:")
    library_output = Bypasser.get_results_from_grouped_items(url, grouped_items, header_line=True, with_filename=False)
    print(library_output)

# do stuff...