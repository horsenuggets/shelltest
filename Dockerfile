# shelltest test environment.

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    findutils \
    grep \
    sed \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /shelltest

COPY . .

RUN chmod +x ./Tools/*.sh ./Tests/*.test.sh

CMD ["./Tools/RunTests.sh", "Tests"]
