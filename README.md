# Next.js docker-compose Boilerplate

This repository provides a quick setup for developing Next.js applications using Docker with docker-compose. It's designed to facilitate VS Code container development without cluttering your host machine with Node.js modules, the Node runtime, npm, or other dependencies. Using Docker volumes for `node_modules` and VS Code container development dependencies allows for faster build times, especially when repeatedly removing and rebuilding the Docker container.

## Getting Started

1. Clone this repository to your local machine:

   ```sh
   git clone https://github.com/coredevel/nextjs-docker-compose.git
   cd nextjs-docker-compose
   ```

2. Run the Docker container:

    ```sh
    docker-compose up --build
    ```

3. Access the development environment through VS Code by attaching to container and opening the /usr/local/src/app folder

### Using the Run Script

By default, there's a run script at ./scripts/run.sh that attempts to install dependencies from package.json on each container run. You can comment out the 2nd line of the script if you find it undesirable for your use case.

### Adding New NPM Dependencies

To add new npm dependencies, open a terminal to the container:

```sh
docker exec -it name-of-container sh
npm install package
```