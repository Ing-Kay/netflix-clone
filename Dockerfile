FROM node:18-slim as builder

WORKDIR /app

# Copy only package.json and yarn.lock first for better caching
COPY package.json yarn.lock ./

RUN yarn config set network-timeout 600000 && \
    yarn install --network-timeout 600000 --frozen-lockfile

# Copy the rest of the app
COPY . .

# Accept TMDB API key as build argument
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

RUN yarn build

# Production image
FROM nginx:stable-alpine

WORKDIR /usr/share/nginx/html

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from builder
COPY --from=builder /app/dist .

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]