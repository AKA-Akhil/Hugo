# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Install required packages
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

# Install Go
RUN wget https://golang.org/dl/go1.21.8.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.8.linux-amd64.tar.gz && \
    rm go1.21.8.linux-amd64.tar.gz

# Set up Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV GOBIN="${GOPATH}/bin"
RUN mkdir -p ${GOPATH}

# Install Hugo from source
RUN CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest

# Ensure the Go bin directory is in the PATH
ENV PATH="${GOPATH}/bin:${PATH}"

# Verify Hugo installation by checking its version
RUN hugo version

# Set the working directory
WORKDIR /site

# Copy the site content into the container
COPY . .

# Expose the port for Hugo
EXPOSE 1313

# Command to run Hugo server
CMD ["hugo", "server", "--bind", "0.0.0.0"]
