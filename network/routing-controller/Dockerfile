FROM docker:cli

RUN apk add --no-cache jq
RUN apk update && apk add --no-cache bash

COPY controller.sh /controller.sh
RUN chmod +x /controller.sh

ENTRYPOINT ["./controller.sh"]

