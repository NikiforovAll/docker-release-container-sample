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

COPY ["src/ReleaseContainerSample/ReleaseContainerSample.csproj", "src/ReleaseContainerSample/"]
COPY ["tests/ReleaseContainerSample.Tests/ReleaseContainerSample.Tests.csproj", "tests/ReleaseContainerSample.Tests/"]

RUN dotnet restore "src/ReleaseContainerSample/ReleaseContainerSample.csproj"

COPY . .

RUN dotnet build "src/ReleaseContainerSample" \
    --configuration $Configuration
    # --no-restore

RUN dotnet test "tests/ReleaseContainerSample.Tests" \
    --configuration $Configuration \
    --no-build

FROM build AS publish

ARG Configuration="Release"
ARG Version=1.0.0

RUN dotnet pack "src/ReleaseContainerSample"\
    -p:Version=$Version \
    --configuration $Configuration \
    --output /artifacts \
    --include-symbols

FROM base AS final

WORKDIR /artifacts
COPY --from=publish /artifacts .

COPY ./build/publish-nuget.sh ./publish-nuget.sh

LABEL org.opencontainers.image.title="ReleaseContainerSample" \
    org.opencontainers.image.description="" \
    org.opencontainers.image.documentation="https://github.com/NikiforovAll/docker-release-container-sample" \
    org.opencontainers.image.source="https://github.com/NikiforovAll/docker-release-container-sample.git" \
    org.opencontainers.image.url="https://github.com/NikiforovAll/docker-release-container-sample" \
    org.opencontainers.image.vendor=""

ENTRYPOINT ["./publish-nuget.sh"]
CMD ["--source", "https://api.nuget.org/v3/index.json"]

