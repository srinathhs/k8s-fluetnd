FROM fluent/fluentd:v1.10-1
MAINTAINER Srinath H S <srinath.hs@gmail.com>

USER root

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo gem install fluent-plugin-elasticsearch \
 && sudo gem install fluent-plugin-s3 -v 1.0.0 \
 && sudo gem install fluent-plugin-grok-parser \
 && sudo gem install fluent-plugin-kafka \
 && sudo gem install fluent-plugin-netflow \
 && sudo gem install fluent-plugin-nats \
 && sudo gem install fluent-plugin-nats-streaming \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

USER fluent
