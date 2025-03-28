FROM --platform=linux/x86-64 debian:bookworm AS build

RUN set -xe ; \
    apt update \ 
    ;

WORKDIR /root

RUN mkdir -p /root/.local/share/OpenArena/baseoa

COPY oa_ded.x86_64 .
COPY baseoa/ /root/.local/share/OpenArena/baseoa

RUN chmod +x oa_ded.x86_64

EXPOSE 27960/udp

FROM alpine:3 AS sys

RUN set -xe; \
    mkdir -p /target/etc; \
    mkdir -p /blank; \
    apk --no-cache add \
      ca-certificates \
      tzdata \
    ; \
    update-ca-certificates; \
    ln -sf ../usr/share/zoneinfo/Etc/UTC /target/etc/localtime; \
    echo "Etc/UTC" > /target/etc/timezone;

FROM scratch

COPY --from=build /root/oa_ded.x86_64 /oa_ded.x86_64
COPY --from=build /root/.local/share/OpenArena //.local/share/OpenArena
COPY --from=build /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libm.so.6
COPY --from=build /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=build /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

# CMD ["./oa_ded.x86_64", "+set", "dedicated", "1", "+map", "oa_dm5"]

