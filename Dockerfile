
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
    wget \
    git \
    gcc \
    g++ \
    build-essential \
    make \
    curl \
    unzip
#
    RUN wget https://golang.org/dl/go1.21.8.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.8.linux-amd64.tar.gz && \
    rm go1.21.8.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV GOBIN="${GOPATH}/bin"
RUN mkdir -p ${GOPATH}

RUN CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest

ENV PATH="${GOPATH}/bin:${PATH}"

RUN hugo version

WORKDIR /site

COPY . .
#
EXPOSE 1313

CMD ["hugo", "server", "--bind", "0.0.0.0"]
