#!/bin/bash

# Ensure script is exec'd from project root
if [ ! -f "docker-compose.yml" ]; then
  echo "Error: Script must be run from the project root"
  exit 1
fi

# Ensure Docker is installed and is at least version 20.10
if ! command -v docker &>/dev/null; then
  echo "Error: Docker is not installed"
  exit 1
fi

# Get Docker version
docker_version=$(docker --version | awk '{print $3}' | cut -d, -f1)
required_version="20.10"

if [ "$(printf '%s\n' "$required_version" "$docker_version" | sort -V | head -n1)" != "$required_version" ]; then
  echo "Error: Docker version must be at least $required_version"
  exit 1
fi

echo "Welcome to the Next.js Containerised Project Management Script!

Easily manage your dockerised Next.js project:
- Build images
- Run containers
- Stop services
- Clean up resources

Get a fully up and running environment with minimal effort.
"

echo -e "Docker version: $docker_version. OK!\n"

main() {
  (
    local MY_UID=$(id -u) # could use $UID or $EUID as they're already set
    local MY_GID=$(id -g)
    local DOCKER_COMPOSE_PROJECT=$(basename "$(pwd)")
    local DEFAULT_TARGET_WORKDIR=/project # default target dir on containter, override in .env
    local ENV_FILE=".env"
    local NEXT_DIR="./next"
    local NODE_MODULES_DIR="$NEXT_DIR/node_modules"
    local DEFAULT_NEXT_VERSION=latest

    # Check if .env file exists, create it if not
    if [ ! -f "$ENV_FILE" ]; then
      touch "$ENV_FILE"
    fi

    # Ensure MY_UID and MY_GID values are up to date in .env file
    if grep -q "MY_UID=" "$ENV_FILE"; then
      sed -i "s/MY_UID=.*/MY_UID=$MY_UID/" "$ENV_FILE"
    else
      echo "MY_UID=$MY_UID" >>"$ENV_FILE"
    fi
    if grep -q "MY_GID=" "$ENV_FILE"; then
      sed -i "s/MY_GID=.*/MY_GID=$MY_GID/" "$ENV_FILE"
    else
      echo "MY_GID=$MY_GID" >>"$ENV_FILE"
    fi

    # Set compose project name based on the parent working project dir, used for filtering / removing volumes
    # Beware, could present trouble if the base dir is renamed and this entry deleted from the .env file
    if ! grep -q "DOCKER_COMPOSE_PROJECT=" "$ENV_FILE"; then
      echo "DOCKER_COMPOSE_PROJECT=$DOCKER_COMPOSE_PROJECT" >>"$ENV_FILE"
    fi

    if ! grep -q "TARGET_WORKDIR=" "$ENV_FILE"; then
      echo "TARGET_WORKDIR=$DEFAULT_TARGET_WORKDIR" >>"$ENV_FILE"
    fi

    if ! grep -q "NEXT_VERSION=" "$ENV_FILE"; then
      echo "NEXT_VERSION=$DEFAULT_NEXT_VERSION" >>"$ENV_FILE"
    fi

    # Ensure the ./next/node_modules directory exists and has the correct ownership
    if [ ! -d "$NODE_MODULES_DIR" ]; then
      echo "Creating $NODE_MODULES_DIR"
      mkdir -p "$NODE_MODULES_DIR"
    fi

    echo "Recursively setting ownership of $NEXT_DIR to UID:GID $MY_UID:$MY_GID"
    chown -R "$MY_UID:$MY_GID" "$NEXT_DIR"

    show_help() {
      echo "Usage: $0 [OPTION]"
      echo ""
      echo "Options:"
      printf "\t%-5s %-15s %-s\n" "-s" "--stop" "Stop the environment"
      printf "\t%-5s %-15s %-s\n" "-d" "--down" "Down the environment (stop and remove containers and network, but not volumes)"
      printf "\t%-5s %-15s %-s\n" "-b" "--build" "Build Docker images"
      printf "\t%-5s %-15s %-s\n" "-r" "--rebuild" "Rebuild Docker images"
      printf "\t%-5s %-15s %-s\n" "-u" "--up" "Run Docker environment with -d flag (default)"
      printf "\t%-5s %-15s %-s\n" "-da" "--drop-all" "Drop all, including the volumes associated with the project"
      printf "\t%-5s %-15s %-s\n" "-h" "--help" "Show this help message"
    }

    stop_containers() {
      docker compose stop
    }

    down_containers() {
      docker compose down
    }

    build_images() {
      docker compose build
    }

    rebuild_images() {
      docker compose build --no-cache
    }

    run_environment() {
      docker compose up
    }

    drop_all() {
      # Get the DOCKER_COMPOSE_PROJECT from the .env file
      local DOCKER_COMPOSE_PROJECT
      DOCKER_COMPOSE_PROJECT=$(grep "^DOCKER_COMPOSE_PROJECT=" "$ENV_FILE" | cut -d '=' -f2-)

      if [ -n "$DOCKER_COMPOSE_PROJECT" ]; then
        echo -e "Dropping all, including the volumes associated with the project...\n"

        # Downing the environment
        printf "%-35s" "Downing the environment..."

        if docker compose down >/dev/null 2>&1; then
          echo -e "\e[32mOK\e[0m"
        else
          echo -e "\e[31mFailed\e[0m"
        fi

        # Removing the volumes
        printf "%-35s" "Removing the volumes..."

        if docker volume ls --filter "label=com.docker.compose.project=$DOCKER_COMPOSE_PROJECT" -q | xargs -r docker volume rm >/dev/null 2>&1; then
          echo -e "\e[32mOK\e[0m"
        else
          echo -e "\e[31mFailed\e[0m"
        fi

      else
        echo "Error: DOCKER_COMPOSE_PROJECT not found in .env file"
        exit 1
      fi
    }

    # Check if any flags were provided
    if [ -z "$1" ]; then
      echo "Starting container"
      run_environment
    else
      # Parse flags
      while [[ $# -gt 0 ]]; do
        case $1 in
        -s | --stop)
          stop_containers
          shift
          ;;
        -d | --down)
          down_containers
          shift
          ;;
        -b | --build)
          build_images
          shift
          ;;
        -r | --rebuild)
          rebuild_images
          shift
          ;;
        -u | --up)
          run_environment
          shift
          ;;
        -da | --drop-all)
          drop_all
          shift
          ;;
        -h | --help)
          show_help
          exit 0
          ;;
        *)
          echo -e "Unknown option: $1\n"
          show_help
          exit 1
          ;;
        esac
      done
    fi
  )
}
main "${@}"
