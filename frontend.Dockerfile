FROM nginx:alpine
# Set working directory to Nginx's web root
WORKDIR /usr/share/nginx/html

## Copy the zipped monorepo archive into the container
# The archive contains both the backend and frontend directories. We extract
# only the frontend portion and copy its contents to the web root so that
# Nginx can serve the static files. We also install unzip, since the base
# Alpine image does not include it by default.
COPY codex-syntaxify-main.zip /tmp/codex-syntaxify-main.zip

RUN apk add --no-cache unzip \
    && unzip -q /tmp/codex-syntaxify-main.zip -d /tmp \
    && cp -r /tmp/codex-syntaxify-main/codex-syntaxify-main/frontend/* . \
    && rm -rf /tmp

EXPOSE 80

# Nginx serves content on port 80 by default. No CMD override is needed