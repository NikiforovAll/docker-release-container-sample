# ReleaseContainerSample

This is an example of how to prepare release container that pushes to private CodeArtifact repository.

## Release

Get $Version:

```bash
export $Version=docker run --rm -v "$(pwd):/repo" gittools/gitversion:5.6.6 /repo \
    | tr { '\n' | tr , '\n' | tr } '\n' \
    | grep "NuGetVersion" \
    | awk -F'"' '{print $4}' | head -n1
```

Build image:

```bash
docker build -f ./src/ReleaseContainerSample/Dockerfile \
    --build-arg Version="$Version" \
    -t release-container-example .
```

Check release content:

```bash
docker run --rm --entrypoint '/bin/ls' --name release-container-sample release-container-example
```

Release NuGet package:

```bash
docker run --rm \
    -e AWS_ACCESS_KEY_ID="" \
    -e AWS_SECRET_ACCESS_KEY="" \
    -e AWS_DEFAULT_REGION="eu-central-1" \
    --name release-container-sample release-container-example \
    --source "https://codeartifact.eu-central-1.amazonaws.com/nuget/codeartifact-repository/v3/index.json"
```
