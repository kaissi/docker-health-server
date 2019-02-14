# Copyright 2018 Marcos Rafael Kaissi Barbosa
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.11.1-alpine3.8 AS build-health-server
ENV CGO_ENABLED 0
ENV GOOS linux
WORKDIR /go/src/github.com/kaissi/health-server
ADD . /go/src/github.com/kaissi/health-server/
RUN go build -ldflags '-w -s' -a -installsuffix cgo -o /go/bin/health-server

FROM alpine:3.8
ARG HEALTH_PORT_TARGET=8081
ENV HEALTH_PORT_TARGET ${HEALTH_PORT_TARGET}
ARG HEALTH_READINESS_FILE="readiness"
ENV HEALTH_READINESS_FILE ${HEALTH_READINESS_FILE}
ARG TZ="Etc/UTC"
ENV TZ ${TZ}
COPY ${HEALTH_READINESS_FILE} /usr/local/health-server/
COPY --from=build-health-server /go/bin/health-server /usr/local/health-server/
RUN apk --no-cache add --update -U \
        curl \
        dumb-init \
        tzdata \
    && cp -v /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && ln -s /usr/local/health-server/${HEALTH_READINESS_FILE} /usr/local/bin/${HEALTH_READINESS_FILE} \
    && ln -s /usr/local/health-server/health-server /usr/local/bin/health-server
VOLUME ["/usr/local/health-server"]
EXPOSE ${HEALTH_PORT_TARGET}
ENTRYPOINT ["/usr/bin/dumb-init", "--", "health-server"]
