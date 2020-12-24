FROM node:lts-alpine as builder

WORKDIR /build
COPY . .
RUN npm ci && \
  npm run build

FROM node:lts-alpine as production
WORKDIR /app

RUN addgroup -S appgroup && \
  adduser -S appuser -G appgroup && \
  apk upgrade --update && \
  npm i next

USER appuser

COPY --from=builder /build/.next .next
COPY --from=builder /build/public public
COPY --from=builder /build/package.json .
COPY --from=builder /build/node_modules node_modules

EXPOSE 3000

ENV NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD wget http://localhost:3000/api/status/v1 -q -O - > /dev/null 2>&1

CMD npm run start
