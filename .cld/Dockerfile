FROM claude-cli-sandbox

USER root

# Shell tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    shellcheck \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Go
COPY --from=golang:1.22-bookworm /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

# kubectl
RUN curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

USER claude
