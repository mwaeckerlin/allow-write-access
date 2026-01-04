FROM mwaeckerlin/very-base AS build
RUN mkdir /app
# Extract busybox binaries and dynamic linker dependencies
# The sed pattern extracts library paths from ldd output: " => /path/to/lib.so ..."
RUN tar cph /app /usr/bin/whoami /bin/ls /bin/chown /bin/sh /bin/sleep /bin/busybox $(ldd /bin/busybox | sed -n 's,.* => \([^ ]*\) .*,\1,p') 2> /dev/null | tar xpC /root/

FROM mwaeckerlin/scratch
COPY --from=build /root/ /
USER root
CMD ["/bin/sh", "-c", "set -- /app/* && (test -e \"$1\" && ls -ld /app/* || ls -ld /app) && echo \"user $(whoami) runs:  ${ALLOW_USER} /app\" && ${ALLOW_USER} /app && set -- /app/* && (test -e \"$1\" && ls -ld /app/* || ls -ld /app) && echo \"done\" && sleep infinity"]
