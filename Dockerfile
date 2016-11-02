FROM anigeo/awscli

RUN apk add -U findutils bash

ENV AWS_DEFAULT_REGION=us-east-1
LABEL io.cmd.description="Lists running ec2 instances across regions"

ADD start /
ENTRYPOINT  [  "/start" ]
