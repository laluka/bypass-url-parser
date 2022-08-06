FROM python:3.11.0b5-bullseye
WORKDIR /bup
COPY . /bup
RUN apt-get install -y curl
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT [ "python", "bypass-url-parser.py" ]