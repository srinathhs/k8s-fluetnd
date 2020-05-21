FROM alpine:3.9
MAINTAINER Srinath H S <srinath.hs@gmail.com>

RUN apk update \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb ruby-etc ruby-webrick \
        tini \
 && apk add --no-cache --virtual .build-deps \
        build-base linux-headers \
        ruby-dev gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.8.1 \
 && gem install json -v 2.3.0 \
 && gem install async-http -v 0.50.7 \
 && gem install ext_monitor -v 0.1.2 \
 && gem install fluentd -v 1.10.3 \
 && gem install bigdecimal -v 1.4.4 \
 && gem install fluent-plugin-elasticsearch \
 && gem install fluent-plugin-s3 -v 1.0.0 \
 && gem install fluent-plugin-grok-parser \
 && gem install fluent-plugin-kafka \
 && gem install fluent-plugin-netflow \
 && gem install fluent-plugin-nats \
 && gem install fluent-plugin-nats-streaming \
 && gem install fluent-plugin-grafana-loki \
 && gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

RUN addgroup -S fluent && adduser -S -g fluent fluent \
    # for log storage (maybe shared with host)
    && mkdir -p /fluentd/log \
    # configuration/plugins path (default: copied from .)
    && mkdir -p /fluentd/etc /fluentd/plugins \
    && chmod +x /bin/entrypoint.sh \
    && chown -R fluent /fluentd && chgrp -R fluent /fluentd

ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
EXPOSE 24224

USER fluent
ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]