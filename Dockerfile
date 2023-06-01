# Build Geth in a stock Go builder container
FROM golang:1.16-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

ADD . /go-ethereum
RUN go env -w GO111MODULE=on
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN cd /go-ethereum && make geth
RUN go install github.com/go-delve/delve/cmd/dlv@latest


# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/
COPY --from=builder  /go/bin/dlv  /usr/local/bin
COPY --from=builder  /go-ethereum/start.sh  /start.sh
EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["sh", "/start.sh"]
