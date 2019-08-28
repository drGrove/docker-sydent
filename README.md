# Matrix Sydent (Dockerfile)

A dockerfile for Sydent: Reference Matrix Identity Server

## Building

```bash
export VERSION=v1.0.3
docker build -t sydent:${VERSION} --build-arg=SYDENT_VERSION=${VERSION} .
```
