FROM ubuntu:22.04 as install

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt update && apt install -y \
    git \
    cmake \
    make \
    gcc \
    g++ \
    flex \
    libfl-dev \
    bison \
    libpcap-dev \
    libssl-dev \
    python3 \
    python3-dev \
    swig \
    zlib1g-dev \
    ca-certificates \
    --no-install-recommends

WORKDIR /root
RUN git clone --recurse-submodules https://github.com/zeek/zeek
WORKDIR /root/zeek
RUN ./configure --prefix=/usr/share/zeek
RUN make && make install

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
    libpcap0.8 \
    git \
    python3 \
    python3-pip \
    jq \
    wget \
    curl \
    net-tools \
    tzdata \
    ca-certificates \
    vim \
    patch \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


COPY --from=install /usr/share/zeek /usr/share/zeek
WORKDIR /usr/share/zeek
COPY capture-loss.zeek.diff /root/
COPY mysql_dpd.sig.diff /root/
COPY mysql__load__.zeek.diff /root/
COPY ja3__load__.zeek.diff /root/
RUN patch /usr/share/zeek/share/zeek/policy/misc/capture-loss.zeek /root/capture-loss.zeek.diff
RUN patch /usr/share/zeek/share/zeek/base/protocols/mysql/__load__.zeek /root/mysql__load__.zeek.diff
RUN patch /usr/share/zeek/share/zeek/base/protocols/mysql/dpd.sig /root/mysql_dpd.sig.diff
RUN python3 -m pip install GitPython semantic-version
RUN update-alternatives --install /usr/bin/bifcl bifcl /usr/share/zeek/bin/bifcl 60000
RUN update-alternatives --install /usr/bin/binpac binpac /usr/share/zeek/bin/binpac 60000
RUN update-alternatives --install /usr/bin/btest btest /usr/share/zeek/bin/btest 60000
RUN update-alternatives --install /usr/bin/btest-ask-update btest-ask-update /usr/share/zeek/bin/btest-ask-update 60000
RUN update-alternatives --install /usr/bin/btest-bg-run btest-bg-run /usr/share/zeek/bin/btest-bg-run 60000
RUN update-alternatives --install /usr/bin/btest-bg-run-helper btest-bg-run-helper /usr/share/zeek/bin/btest-bg-run-helper 60000
RUN update-alternatives --install /usr/bin/btest-bg-wait btest-bg-wait /usr/share/zeek/bin/btest-bg-wait 60000
RUN update-alternatives --install /usr/bin/btest-diff btest-diff /usr/share/zeek/bin/btest-diff 60000
RUN update-alternatives --install /usr/bin/btest-diff-rst btest-diff-rst /usr/share/zeek/bin/btest-diff-rst 60000
RUN update-alternatives --install /usr/bin/btest-progress btest-progress /usr/share/zeek/bin/btest-progress 60000
RUN update-alternatives --install /usr/bin/btest-rst-cmd btest-rst-cmd /usr/share/zeek/bin/btest-rst-cmd 60000
RUN update-alternatives --install /usr/bin/btest-rst-include btest-rst-include /usr/share/zeek/bin/btest-rst-include 60000
RUN update-alternatives --install /usr/bin/btest-rst-pipe btest-rst-pipe /usr/share/zeek/bin/btest-rst-pipe 60000
RUN update-alternatives --install /usr/bin/btest-setsid btest-setsid /usr/share/zeek/bin/btest-setsid 60000
RUN update-alternatives --install /usr/bin/capstats capstats /usr/share/zeek/bin/capstats 60000
RUN update-alternatives --install /usr/bin/gen-zam gen-zam /usr/share/zeek/bin/gen-zam 60000
RUN update-alternatives --install /usr/bin/hilti-config hilti-config /usr/share/zeek/bin/hilti-config 60000
RUN update-alternatives --install /usr/bin/hiltic hiltic /usr/share/zeek/bin/hiltic 60000
RUN update-alternatives --install /usr/bin/paraglob-test paraglob-test /usr/share/zeek/bin/paraglob-test 60000
RUN update-alternatives --install /usr/bin/spicy-build spicy-build /usr/share/zeek/bin/spicy-build 60000
RUN update-alternatives --install /usr/bin/spicy-config spicy-config /usr/share/zeek/bin/spicy-config 60000
RUN update-alternatives --install /usr/bin/spicy-driver spicy-driver /usr/share/zeek/bin/spicy-driver 60000
RUN update-alternatives --install /usr/bin/spicy-dump spicy-dump /usr/share/zeek/bin/spicy-dump 60000
RUN update-alternatives --install /usr/bin/spicy-precompile-headers spicy-precompile-headers /usr/share/zeek/bin/spicy-precompile-headers 60000
RUN update-alternatives --install /usr/bin/spicyc spicyc /usr/share/zeek/bin/spicyc 60000
RUN update-alternatives --install /usr/bin/spicyz spicyz /usr/share/zeek/bin/spicyz 60000
RUN update-alternatives --install /usr/bin/trace-summary trace-summary /usr/share/zeek/bin/trace-summary 60000
RUN update-alternatives --install /usr/bin/zeek zeek /usr/share/zeek/bin/zeek 60000
RUN update-alternatives --install /usr/bin/zeek-archiver zeek-archiver /usr/share/zeek/bin/zeek-archiver 60000
RUN update-alternatives --install /usr/bin/zeek-client zeek-client /usr/share/zeek/bin/zeek-client 60000
RUN update-alternatives --install /usr/bin/zeek-config zeek-config /usr/share/zeek/bin/zeek-config 60000
RUN update-alternatives --install /usr/bin/zeek-cut zeek-cut /usr/share/zeek/bin/zeek-cut 60000
RUN update-alternatives --install /usr/bin/zeekctl zeekctl /usr/share/zeek/bin/zeekctl 60000
RUN update-alternatives --install /usr/bin/zkg zkg /usr/share/zeek/bin/zkg 60000
RUN zkg -vvv install --force ja3
RUN patch /usr/share/zeek/share/zeek/site/packages/ja3/__load__.zeek /root/ja3__load__.zeek.diff
RUN mkdir -p /usr/share/zeek/share/zeek/site/signatures

