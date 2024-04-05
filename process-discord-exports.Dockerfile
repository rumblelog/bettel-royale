ARG DOTNET_VERSION=8.0.203

###

FROM golang:1.22-alpine

RUN apk add --no-cache make git sqlite-libs alpine-sdk

WORKDIR /usr/src/hololive-bettel-royale-data-processing
COPY . .
ENV GOBIN /usr/local/bin/
ENV CGO_ENABLED 1
RUN make bins

###

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION}-alpine3.19-amd64

WORKDIR /usr/src/hololive-bettel-royale-data-processing/submodules/DiscordChatExporter
COPY ./submodules/DiscordChatExporter/ .
ARG TARGETARCH
RUN dotnet restore -a $TARGETARCH ./DiscordChatExporter.Cli/DiscordChatExporter.Cli.csproj
ARG DCE_BUILD_CONFIGURATION=Release
RUN dotnet publish --no-restore -a $TARGETARCH -o /opt/DiscordChatExporter ./DiscordChatExporter.Cli/DiscordChatExporter.Cli.csproj
#RUN dotnet build --configuration ${DCE_BUILD_CONFIGURATION} ./DiscordChatExporter.Cli/DiscordChatExporter.Cli.csproj

###

FROM alpine:edge

RUN apk add --no-cache make git openssh-client jq dotnet8-runtime gnupg sqlite-libs grep

# # install dotnet
# ADD https://dot.net/v1/dotnet-install.sh dotnet-install.sh
# ARG DOTNET_CHANNEL=8.0
# ARG DOTNET_VERSION=8.0.203
# RUN apk add --no-cache bash &&\
#     bash ./dotnet-install.sh --install-dir /opt/dotnet --channel "${DOTNET_CHANNEL}" --version "${DOTNET_VERSION}" &&\
#     rm dotnet-install.sh &&\
#     apk del --no-cache bash
# ENV DOTNET_ROOT /opt/dotnet
# ENV DOTNET /opt/dotnet/dotnet

WORKDIR /usr/src/hololive-bettel-royale-data-processing
COPY --from=1 \ 
    /opt/DiscordChatExporter/ \
    /opt/DiscordChatExporter/
COPY --from=0 \
    /usr/src/hololive-bettel-royale-data-processing/process-discord-exports \
    /usr/src/hololive-bettel-royale-data-processing/Makefile \
    ./

# modify Makefile dependencies to not try and build DCE at runtime
ENV DCE_BIN_PATH /opt/DiscordChatExporter/DiscordChatExporter.Cli

# do not use dotnet wrapper
ENV DCE_CMD /opt/DiscordChatExporter/DiscordChatExporter.Cli

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER 999

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "make", "refresh-dumps", "-e" ]
