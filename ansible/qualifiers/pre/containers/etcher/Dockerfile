FROM debian:12-slim AS build
RUN apt-get clean && \
    apt-get update --allow-releaseinfo-change && \
    apt-get install --no-install-suggests --no-install-recommends --yes gcc libpython3-dev python3-venv && \
    python3 -m venv /venv

COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt

# Copy the virtualenv into a distroless image
FROM gcr.io/distroless/python3-debian12:nonroot
COPY --from=build /venv /venv
COPY server.py /app/server.py
WORKDIR /app

EXPOSE 5000
ENTRYPOINT ["/venv/bin/python3", "server.py"]
