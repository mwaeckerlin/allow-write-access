FROM mwaeckerlin/very-base AS build
RUN tar cph /bin/chown /bin/sh /bin/sleep /bin/busybox $(ldd /bin/busybox | sed -n 's,.* => \([^ ]*\) .*,\1,p') 2> /dev/null | tar xpC /root/

FROM mwaeckerlin/scratch
COPY --from=build /root/ /
CMD ["/bin/sh", "-c", "$${ALLOW_USER} /app"]
