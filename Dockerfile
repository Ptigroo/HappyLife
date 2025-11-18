# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["HappyLife/HappyLife.csproj", "HappyLife/"]
COPY ["HappyLifeModels/HappyLifeModels.csproj", "HappyLifeModels/"]
COPY ["HappyLifeRepository/HappyLifeRepository.csproj", "HappyLifeRepository/"]
COPY ["HappyLifeServices/HappyLifeServices.csproj", "HappyLifeServices/"]
COPY ["HappyLifeInterfaces/HappyLifeInterfaces.csproj", "HappyLifeInterfaces/"]

RUN dotnet restore "HappyLife/HappyLife.csproj"

# Copy the rest of the source code
COPY . .

# Build the application
WORKDIR "/src/HappyLife"
RUN dotnet build "HappyLife.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "HappyLife.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage/runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy published application
COPY --from=publish /app/publish .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "HappyLife.dll"]
