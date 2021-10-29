# bypass-url-parser

Tool that tests `MANY` url bypass to reach a `40X protected page`.


## How to, Setup, Use

```bash
# Setup
git clone https://github.com/laluka/bypass-url-parser
sudo mv bypass-url-parser /opt/
# Add this to your aliases
alias bypass='f(){ /opt/bypass-url-parser/bypass.sh -u $@ 2>&1 | tee bypass-$(date +%s%N).log;  unset -f f; }; f'
# Use it
./bypass.sh http://127.0.0.1/
./bypass.sh http://127.0.0.1/blocked/path/
```


## Dirty code disclaimer

The code is bad. Like, really bad.

A first python-base approach was made, but the issue if that while we're not using raw sockets, too many wrappers are decoding/encoding the url before sending it to the server, so it was a pain to send our actual payloads to the server, thus here we are, in 2021, using `curl --path-as-is -skg`, and it works smoothly!


## Contribute

1. Fork this repo
1. `git checkout -b "$USER/$FEATURE"`
1. Implement your feature / refactor
1. `git push --set-upstream origin "$USER/$FEATURE"`
1. Create pull request that we'll be happy to review :)
