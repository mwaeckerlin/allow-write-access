FROM mwaeckerlin/very-base AS build
# Extract busybox binaries and dynamic linker dependencies
# The sed pattern extracts library paths from ldd output: " => /path/to/lib.so ..."
RUN tar cph /bin/chown /bin/sh /bin/sleep /bin/busybox $(ldd /bin/busybox | sed -n 's,.* => \([^ ]*\) .*,\1,p') 2> /dev/null | tar xpC /root/

FROM mwaeckerlin/scratch
COPY --from=build /root/ /
CMD ["/bin/sh", "-c", "$${ALLOW_USER} /app"]
