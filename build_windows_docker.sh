#!/bin/bash

set -e

echo "Building OrcaSlicer for Windows using Docker"
echo "This will create a Windows portable executable"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running"
    echo "Please start Docker and try again"
    exit 1
fi

# Create a temporary Dockerfile for Windows build
cat > Dockerfile.windows << 'DOCKEREOF'
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install Chocolatey
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install build tools
RUN choco install -y \
    visualstudio2019buildtools \
    visualstudio2019-workload-vctools \
    cmake \
    git \
    python3 \
    ninja

# Set environment variables
ENV PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64;${PATH}"

# Clone OrcaSlicer
RUN git clone https://github.com/SoftFever/OrcaSlicer.git C:\OrcaSlicer

# Set working directory
WORKDIR C:\OrcaSlicer

# Build dependencies
RUN cmake -B build-deps -S deps -G "Visual Studio 16 2019" -A x64 -DDESTDIR=C:\OrcaSlicer\build-deps\OrcaSlicer_dep
RUN cmake --build build-deps --config Release --target deps

# Build OrcaSlicer
RUN cmake -B build -S . -G "Visual Studio 16 2019" -A x64 -DBBL_RELEASE_TO_PUBLIC=1 -DCMAKE_PREFIX_PATH=C:\OrcaSlicer\build-deps\OrcaSlicer_dep\usr\local -DCMAKE_INSTALL_PREFIX=C:\OrcaSlicer\build\OrcaSlicer
RUN cmake --build build --config Release --target ALL_BUILD
RUN cmake --build build --target install --config Release

# Create portable package
RUN powershell -Command \
    $buildDir = "C:\OrcaSlicer\build\OrcaSlicer"; \
    $portableDir = "C:\OrcaSlicer\OrcaSlicer-Windows-Portable"; \
    New-Item -ItemType Directory -Path $portableDir -Force; \
    Copy-Item -Path "$buildDir\*" -Destination $portableDir -Recurse -Force; \
    Compress-Archive -Path $portableDir -DestinationPath "C:\OrcaSlicer\OrcaSlicer-Windows-Portable.zip"

# Keep container running for file extraction
CMD ["cmd", "/k"]
DOCKEREOF

echo "Building Windows executable in Docker container..."
echo "This may take a long time (30-60 minutes)..."

# Build the Docker image
docker build -f Dockerfile.windows -t orcaslicer-windows-build .

# Create a container and copy the built files
echo "Creating container and extracting built files..."
CONTAINER_ID=$(docker create orcaslicer-windows-build)

# Copy the built executable and portable package
docker cp $CONTAINER_ID:/OrcaSlicer/OrcaSlicer-Windows-Portable.zip ./
docker cp $CONTAINER_ID:/OrcaSlicer/build/OrcaSlicer/ ./

# Clean up
docker rm $CONTAINER_ID
rm Dockerfile.windows

echo "Build completed!"
echo "Windows executable: ./OrcaSlicer/orca-slicer.exe"
echo "Portable package: ./OrcaSlicer-Windows-Portable.zip"

# Verify the build
if [ -f "./OrcaSlicer/orca-slicer.exe" ]; then
    echo "✅ Windows executable built successfully!"
    ls -la ./OrcaSlicer/
else
    echo "❌ Build failed - executable not found"
    exit 1
fi
