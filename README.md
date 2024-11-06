# BlockMesh Network Node Setup

This repository provides an automated setup script to configure and install a BlockMesh network node. This script downloads, cleans, and sets execution permissions for the `Blockmesh.sh` setup script, simplifying the deployment process for new nodes.

## Usage

To execute the setup script, run the following command in your terminal:

```bash
wget -O Blockmesh.sh https://raw.githubusercontent.com/ByteBeggar/BlockMeshNetwor-Node/refs/heads/main/Blockmesh.sh && sed -i 's/\r$//' Blockmesh.sh && chmod +x Blockmesh.sh && ./Blockmesh.sh
