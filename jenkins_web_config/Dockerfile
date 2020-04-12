FROM alpine:3.9

RUN \
  # update packages
  apk update && apk upgrade && \
  # install ruby
  apk --no-cache add ruby ruby-dev ruby-bundler ruby-json ruby-irb ruby-rake ruby-bigdecimal && \
  # gem 'oj', 'puma', 'byebug'
  apk --no-cache add make gcc libc-dev libuuid && \
  # install etc.
  apk add bash curl git && \
  # clear after installation
  rm -rf /var/cache/apk/*

# to avoid installing documentation for gems
COPY gemrc /root/.gemrc

# use mounted volume for gems
ENV BUNDLE_PATH /bundle

# create WORKDIR
ENV WORKDIR /work
RUN mkdir $WORKDIR
WORKDIR $WORKDIR

COPY . .
RUN bundle install
