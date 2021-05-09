FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS base


RUN apt-get update && apt install unzip && apt-get install -y curl
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip && ./aws/install

WORKDIR /artifacts
RUN dotnet new tool-manifest --name manifest
RUN dotnet tool install --ignore-failed-sources AWS.CodeArtifact.NuGet.CredentialProvider

RUN dotnet codeartifact-creds install

FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build

# To use the debug build configuration pass --build-arg Configuration=Debug
ARG Configuration="Release"

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true

WORKDIR /src

COPY ["src/Directory.Build.props", "src/"]
COPY ["src/Epam.MentorHub.Messaging/Epam.MentorHub.Messaging.csproj", "src/Epam.MentorHub.Messaging/"]
COPY ["src/Epam.MentorHub.Messaging.Abstractions/Epam.MentorHub.Messaging.Abstractions.csproj", "src/Epam.MentorHub.Messaging.Abstractions/"]

RUN dotnet restore "src/Epam.MentorHub.Messaging.Abstractions/Epam.MentorHub.Messaging.Abstractions.csproj"
RUN dotnet restore "src/Epam.MentorHub.Messaging/Epam.MentorHub.Messaging.csproj"

COPY . .

RUN dotnet build "src/Epam.MentorHub.Messaging" \
    --configuration $Configuration
    # --no-restore

RUN dotnet test "tests/Epam.MentorHub.Messaging.UnitTests" \
    --configuration $Configuration \
    --no-build

FROM build AS publish

ARG Configuration="Release"
ARG Version=1.0.0

RUN dotnet pack \
    -p:Version=$Version \
    --configuration $Configuration \
    --output /artifacts \
    ## --include-source \
    --include-symbols

FROM base AS final

LABEL org.opencontainers.image.title="Epam.MentorHub.Messaging" \
    org.opencontainers.image.description="" \
    org.opencontainers.image.documentation="https://kb.epam.com/display/EPMDUBFM/EPMD-UBFM+Home" \
    org.opencontainers.image.source="https://git.epam.com/epmd-ubfm/epam.mentorhub.messaging.git" \
    org.opencontainers.image.url="https://git.epam.com/epmd-ubfm/epam.mentorhub.messaging" \
    org.opencontainers.image.vendor="EPAM"

WORKDIR /artifacts
COPY --from=publish /artifacts .

COPY ./build/release-nuget.sh ./release-nuget.sh

RUN chmod +x ./release-nuget.sh
ENTRYPOINT ["./release-nuget.sh"]
CMD ["--source", "https://api.nuget.org/v3/index.json"]

