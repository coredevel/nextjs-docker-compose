#!/bin/bash

set -e

if [ -z "$TARGET_WORKDIR" ]; then
  echo "Error: TARGET_WORKDIR is not set."
  exit 1
fi

next_project_dir=${TARGET_WORKDIR}/next
next_version=${NEXT_VERSION}

# during build let's initialise a default next js project with sensible defaults (each to their own ofc, modify as necessary before running)
# we have to bootstrap the app in the /tmp dir and copy files into the next_project_dir due to the the node_modules docker compose mount which prevents create-next-app from succeeding due to existing files in the target dir, so we skip install here, copy everything over then install node modules later

# test if the target next project dir is empty (minus the node_modules mount) and if so start bootstrapping
if [ ! -d "$next_project_dir" ] || [ -z "$(ls -A "$next_project_dir" | grep -v '^node_modules$' | head -n1)" ]; then

  # this uses `create-next-app` for bootstrapping, run `npx create-next-app@latest`
  # to see available options

  echo "Initializing Next.js project..."

  # Initialize in a temporary directory
  tmp_dir="/tmp/next_app"

  echo "Clearing any existing temporary files"
  rm -rf "$tmp_dir" || {
    echo "Failed to remove temporary files"
    exit 1
  }

  echo "Ensuring temp dir exists"
  mkdir -p "$tmp_dir" || {
    echo "Failed to create temp dir"
    exit 1
  }

  echo "Switching to temp dir"
  cd "$tmp_dir" || {
    echo "Failed to change directory to temp dir"
    exit 1
  }

  # Initialize Next.js project
  echo "Running create-next-app for version $NEXT_VERSION..."

  if ! npx --yes create-next-app@$NEXT_VERSION . --yes \
    --ts \
    --tailwind \
    --eslint \
    --app \
    --src-dir \
    --use-npm \
    --import-alias "@/*" \
    --skip-install; then
    echo "Next.js project initialization failed."
    exit 1
  fi

  # it can easily be swapped out with t3 starter,
  # see https://create.t3.gg/en/installation for options
  # note: not tested, and may have issues re src/ dir
  # npx create t3-app@latest \
  #   --noGit
  #   --CI \
  #   --trpc \
  #   --prisma \
  #   --nextAuth \
  #   --tailwind \
  #   --dbProvider mysql

  # ensure working directory exists
  mkdir -p $next_project_dir || {
    echo "Failed to create directory: $next_project_dir"
    exit 1
  }

  cp -R . "$next_project_dir" || {
    echo "Failed to copy files across"
    exit 1
  }

  rm -rf "$tmp_dir" || {
    echo "Failed to remove temporary files"
    exit 1
  }

  # chown -R "$(id -u):$(id -g)" "$next_project_dir"

else
  echo "Next.js project already initialized, skipping bootstrapping."
fi

if [ -z "$(ls -A "$next_project_dir/node_modules" | head -n1)" ]; then
  # Install node modules (required to run separately to the above if the docker volume is destroyed after the project has been initialised or an existing project has been dropped in)

  echo "Installing node modules..."

  # navigate to the working directory
  cd $next_project_dir || {
    echo "Failed to navigate to directory: $next_project_dir"
    exit 1
  }

  npm install --loglevel verbose

fi
