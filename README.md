# Next.js Project Starter Kit with docker compose for VS Code Dev Containers

**UPDATE 2024-10-31: Happy Halloween 🎃** Now supports Next.js 15 (or another other version you'd like to use)

This repository provides a rapid one command setup for developing a new Next.js application in a docker compose environment. It's designed to facilitate VS Code container development without cluttering your host machine with Node.js modules, the Node runtime, npm, or dependencies other than docker itself. Using Docker volumes for `node_modules` and VS Code container dev dependencies allows for faster build times, especially when repeatedly removing and rebuilding the Docker container should you need to for whatever reason, e.g. os level packages, other deps or customisations. The dev container is now pretty much a replica of what you'd use in a production k8s cluster... with some required tweaks, a build process and testing of course.

By default it sets up a new project with the following enabled:

- Typescript
- Src dir
- App dir
- Eslint
- Tailwind
- NPM

Theoretically it should be possible to drop an existing next.js project into the ./next/ directory and have it boot but this is untested as yet.

## Getting Started

1. Clone this repository to your local machine and run the below (preferably in a terminal separate to VS Code, as we'll be attaching to the container with that later on):

   ```sh
   git clone https://github.com/coredevel/nextjs-docker-compose.git
   cd nextjs-docker-compose
   # optionally delete the git folder and reinitialise
   rm -rf .git
   git init
   ```

2. Run the Docker container:

   ```sh
   ./dc.sh
   ```

3. Once it's built you'll see it's serving, simply go to [http://localhost:3000](http://localhost:3000) and the next.js boiler plate is served up good to go.

4. Next, access the development environment through VS Code by attaching to container and opening the `/project/next` folder and you're ready to develop

**Note**, remember to delete the .git folder, and reinitialise if you wish to version control your own project/work!

### Using the Run Script (./dc.sh)

There's a script at `./dc.sh` (_*short for docker compose*_ :) ) which contains some helper and convenient functions to easily manage your dockerised Next.js project:

- Build images
- Run containers
- Stop services
- Clean up resources

When running the script it'll perform some preflight checks and create a .env file if one doesn't exist, and set a bunch of defaults, there's no need to create this manually to use this repo as is to get a Next.js project in a docker compose environment up and running but there is a .env.example provided which can be copied to .env and values modified.

#### Usage:

```bash
./dc.sh [OPTION]
```

#### Options:

- -u --up  
  Run Docker environment (note, without detached mode)

- -s --stop  
  Stop the environment

- -d --down  
  Down the environment (stop and remove containers and network, but not volumes)

- -b --build  
  Build Docker images

- -r --rebuild  
  Rebuild Docker images (without using cached layers)

- -da --drop-all  
  Drop all, including the volumes associated with the project

- -h --help  
  Show the help message

### Adding New NPM Dependencies

To add new npm dependencies, either:

1. Open a VS Code integrated terminal while attached to the running container and run `npm install package-name` as usual; or

2. Open a terminal to the container via docker exec:

   ```sh
   docker exec -it node-nextjs bash
   npm install package
   ```

### Changing Next version

By default this will run npx create-next-app@latest, where latest is pulled from the .env file, that's initialised when first running `./dc.sh`.
Copy .env.example to .env and update the `NEXT_VERSION` value to your desired version.
Ensure that the DOCKER_COMPOSE_PROJECT value is reflective of the directory name the repo was cloned to, e.g. if cloned to `/home/user/projects/nextjs-docker-compose`, the value would be `nextjs-docker-compose`. This is required for volume clean ups where they are filtered on the `com.docker.compose.project` label and removed accordingly.

### Changing the install options

In the `./.docker/scripts/bootstrap.sh` you'll see the `npx` command, modify as necessary, but be aware that some versions of `create-next-app` the --yes flag doesn't work and causes the script to appear as if it's 'hanging', whereas it's waiting on interactive input which we don't have available when running `docker compose up`. So it's best to ensure all options/flags are set to avoid any install questions being asked.

### Issues

Any issues, feedback or changes please feel free to open tickets or PRs. Thanks.
