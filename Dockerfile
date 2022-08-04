FROM python:3.11.0b5-alpine3.16
WORKDIR /bup
COPY . /bup
RUN apk add curl
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT [ "python", "bypass-url-parser.py" ]