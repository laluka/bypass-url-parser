FROM python:3.12.0a4-slim-bullseye
WORKDIR /bup
COPY . /bup
RUN pip install --no-cache-dir -r requirements.txt
RUN apt-get update && apt-get install -y curl
ENTRYPOINT [ "python", "bypass-url-parser.py" ]
