FROM debian:bookworm-slim AS builder

ARG SING_BOX_VERSION="1.8.11"
ARG SING_BOX_URL="https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/"

RUN set -eux \
    && apt-get update -qyy \
    && apt-get install -qyy --no-install-recommends --no-install-suggests \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/* /var/log/* \
    \
    && ARCH=`uname -m` \
    && case "$ARCH" in \
    "x86_64") \
    SING_BOX_FILENAME="sing-box-${SING_BOX_VERSION}-linux-amd64.tar.gz" \
    ;; \
    "aarch64") \
    SING_BOX_FILENAME="sing-box-${SING_BOX_VERSION}-linux-arm64.tar.gz" \
    ;; \
    esac \
    \
    && curl -fsSL "${SING_BOX_URL}${SING_BOX_FILENAME}" -o sing-box.tar.gz \
    && tar -xzvf sing-box.tar.gz \
    && mv sing-box*/sing-box /usr/local/bin/sing-box \
    && rm -rf sing-box*

######

FROM debian:bookworm-slim

COPY --from=builder /usr/local/bin/ /usr/local/bin/

RUN set -eux \
    && apt-get update -qyy \
    && apt-get install -qyy --no-install-recommends --no-install-suggests \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* /var/log/*
# ADD https://github.com/malikshi/sing-box-geo/releases/latest/download/geoip.db geoip.db
# ADD https://github.com/chocolate4u/Iran-sing-box-rules/releases/latest/download/geosite.db geosite.db
#ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
#ADD https://github.com/J-Saeedi/iran_profile_for_internet/raw/main/01.json /tmp/01.json
COPY geoip.db /geoip.db
COPY geosite.db /geosite.db
COPY 01.json /tmp/01.json
ENTRYPOINT ["/usr/local/bin/sing-box", "run", "-C", "/tmp"]
