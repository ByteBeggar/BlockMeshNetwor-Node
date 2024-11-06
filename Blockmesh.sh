#!/bin/bash

# Script save path
SCRIPT_PATH="$HOME/BlockMesh.sh"

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script needs to be run as root."
    echo "Try switching to root user with 'sudo -i' and then rerun the script."
    exit 1
fi

# Main menu function
function main_menu() {
    while true; do
        clear
        echo "The official version updates too quickly. Update the version number in the code for the latest version, then rerun."
        echo "For issues, contact Twitter @goway2024"
        echo "================================================================"
        echo "To exit the script, press ctrl + C."
        echo "Select the operation to execute:"
        echo "1. Deploy Node"
        echo "2. View Logs"
        echo "3. Exit"

        read -p "Enter an option (1-3): " option

        case $option in
            1)
                deploy_node
                ;;
            2)
                view_logs
                ;;
            3)
                echo "Exiting script."
                exit 0
                ;;
            *)
                echo "Invalid option. Please enter again."
                read -p "Press any key to continue..."
                ;;
        esac
    done
}

# Deploy node
function deploy_node() {
    echo "Updating the system..."
    sudo apt update -y && sudo apt upgrade -y

    # Clean up old files
    rm -rf blockmesh-cli.tar.gz target

    # Check and handle existing containers
    if [ "$(docker ps -aq -f name=blockmesh-cli-container)" ]; then
        echo "Detected existing blockmesh-cli-container. Stopping and removing..."
        docker stop blockmesh-cli-container
        docker rm blockmesh-cli-container
        echo "Container stopped and removed."
    fi

    # Install Docker if not installed
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        apt-get install -y \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
    else
        echo "Docker is already installed. Skipping installation..."
    fi

    # Install Docker Compose
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Create target directory for extraction
    mkdir -p target/release

    # Download and extract the latest BlockMesh CLI
    echo "Downloading and extracting BlockMesh CLI..."
    curl -L https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.340/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz -o blockmesh-cli.tar.gz
    tar -xzf blockmesh-cli.tar.gz --strip-components=3 -C target/release

    # Verify extraction
    if [[ ! -f target/release/blockmesh-cli ]]; then
        echo "Error: blockmesh-cli executable not found in target/release. Exiting..."
        exit 1
    fi

    # Prompt for email and password
    read -p "Enter your BlockMesh email: " email
    read -s -p "Enter your BlockMesh password: " password
    echo

    # Create Docker container with BlockMesh CLI
    echo "Creating Docker container for BlockMesh CLI..."
    docker run -it --rm \
        --name blockmesh-cli-container \
        -v $(pwd)/target/release:/app \
        -e EMAIL="$email" \
        -e PASSWORD="$password" \
        --workdir /app \
        ubuntu:22.04 ./blockmesh-cli --email "$email" --password "$password"

    read -p "Press any key to return to the main menu..."
}

# View logs
function view_logs() {
    # View the last 100 lines of logs from the blockmesh-cli-container
    echo "Viewing logs of blockmesh-cli-container:"
    docker logs --tail 100 blockmesh-cli-container

    # Check if container exists
    if [ $? -ne 0 ]; then
        echo "Error: No container named blockmesh-cli-container found."
    fi

    read -p "Press any key to return to the main menu..."
}

# Start main menu
main_menu
