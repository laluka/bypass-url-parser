FROM python:3.11.0b5-slim-bullseye
WORKDIR /bup
COPY . /bup
RUN pip install --no-cache-dir -r requirements.txt
RUN apt-get update && apt-get install -y curl
ENTRYPOINT [ "python", "bypass-url-parser.py" ]