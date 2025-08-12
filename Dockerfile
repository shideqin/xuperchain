FROM golang:1.24.6 AS builder
WORKDIR /home/xchain

RUN apt update && apt install -y unzip

# 设置时区为 Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

# small trick to take advantage of  docker build cache
COPY go.* ./
COPY Makefile .
RUN make prepare

COPY . .
RUN make

# ---
FROM ubuntu:22.04
WORKDIR /home/xchain
RUN apt update&& apt install -y build-essential
COPY --from=builder /home/xchain/output .
EXPOSE 37101 47101
CMD ["bash", "control.sh", "start", "-f"]
