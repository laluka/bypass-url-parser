FROM python:3.12.0b4-slim-bullseye
WORKDIR /bup
COPY . /bup
RUN pip install --no-cache-dir -r requirements.txt
RUN apt-get update && apt-get install -y curl
ENTRYPOINT [ "python", "bypass_url_parser.py" ]
