FROM ubuntu/squid

COPY squid.conf /etc/squid/squid.conf

RUN squid -z

CMD ["squid", "-N", "-f", "/etc/squid/squid.conf"]

EXPOSE 3128
