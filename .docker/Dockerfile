FROM node:lts-bullseye

# Declare build arguments and set default values
ARG TARGET_WORKDIR=/project
ARG MY_UID=1000
ARG MY_GID=1000

# Set the TARGET_WORKDIR environment variable for bootstrap script
ENV TARGET_WORKDIR=${TARGET_WORKDIR}

WORKDIR ${TARGET_WORKDIR}

RUN apt update && apt upgrade -y

# Create a user and group if they don't already exist
RUN \
  if ! getent group ${MY_GID} >/dev/null; then \
    groupadd -g ${MY_GID} container_group; \
  else \
    groupmod -n container_group $(getent group ${MY_GID} | cut -d: -f1); \
  fi && \
  if ! getent passwd ${MY_UID} >/dev/null; then \
    useradd -u ${MY_UID} -g ${MY_GID} -m container_user; \
  else \
    usermod -d /home/container_user -l container_user $(getent passwd ${MY_UID} | cut -d: -f1); \
  fi

  # Ensure the home directory is owned by container_user
RUN mkdir -p /home/container_user
RUN chown -R container_user:container_group /home/container_user

# Ensure the project directory is prepped for the node_modules mount and owned by container_user
RUN mkdir -p ${TARGET_WORKDIR}/next/node_modules
RUN chown -R container_user:container_group ${TARGET_WORKDIR}

# Copy entrypoint script into the image
COPY ./.docker/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to the non-root user
USER container_user

# Set NPM directories to user's home directory
RUN mkdir -p /home/container_user/.npm /home/container_user/.npm-global
RUN npm config set prefix /home/container_user/.npm-global
RUN npm config set cache /home/container_user/.npm

# Update PATH environment variable
ENV PATH=$PATH:/home/container_user/.npm-global/bin

# Install global npm packages as non-root user
RUN npm install -g npm

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Expose port 3000
EXPOSE 3000

# Default command
CMD ["bash"]