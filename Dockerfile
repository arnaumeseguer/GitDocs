FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY frontend/pubspec.yaml frontend/pubspec.lock frontend/
WORKDIR /app/frontend
RUN flutter pub get
COPY frontend/ /app/frontend/
RUN flutter build web --release

FROM node:20-alpine AS runtime
WORKDIR /app
RUN npm install -g serve
COPY --from=build /app/frontend/build/web ./web
ENV PORT=8080
CMD ["sh", "-c", "serve -s web -l ${PORT:-8080}"]
