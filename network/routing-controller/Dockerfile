FROM docker:cli

# Install jq
RUN apk add --no-cache jq

COPY controller.sh /controller.sh
RUN chmod +x /controller.sh

ENTRYPOINT ["/controller.sh"]

