FROM ubuntu:latest
MAINTAINER Shusui Moyatani

RUN    apt-get update \
    && apt-get install -y git python3 \
	   libaio-dev ninja-build ragel libhwloc-dev libnuma-dev libpciaccess-dev libcrypto++-dev libboost-all-dev libxen-dev libxml2-dev xfslibs-dev \
	&& git clone https://github.com/fastio/pedis.git /opt/pedis \
	&& cd /opt/pedis \
	&& git config --local --replace-all "submodule.seastar.url" "https://github.com/scylladb/seastar.git" \
	&& git config --local --replace-all "submodule.tests/gtest.url" "https://github.com/google/googletest.git" \
	&& git submodule update --init --recursive \
	&& ./seastar/install-dependencies.sh \
	&& python3 configure.py \
	&& ninja -j2

EXPOSE 6379

CMD '/opt/pedis/build/release/pedis'
