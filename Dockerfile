FROM mcr.microsoft.com/dotnet/runtime:6.0-focal AS base
WORKDIR /app

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build
WORKDIR /src
COPY ["k8sApp.csproj", "./"]
RUN dotnet restore "k8sApp.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "k8sApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "k8sApp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "k8sApp.dll"]
