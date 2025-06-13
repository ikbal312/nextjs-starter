# this was build by following this guide line
# https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile

FROM node:21.1.0-alpine AS base
RUN mkdir -p /var/www/frontend
WORKDIR /var/www/frontend
COPY package*.json ./
RUN npm ci
ENV NEXT_TELEMETRY_DISABLED=1

# # Builder stage
FROM base AS builder
WORKDIR /var/www/frontend
COPY --from=base /var/www/frontend/node_modules ./node_modules
COPY . .
RUN npm run  build
# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# the following line  disable telemetry during the build.
ENV NEXT_TELEMETRY_DISABLED=1

# Production image
FROM node:21.1.0-alpine AS runner
WORKDIR /var/www/frontend
ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /var/www/frontend/public ./public
COPY --from=builder --chown=nextjs:nodejs /var/www/frontend/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /var/www/frontend/.next/static ./.next/static
USER nextjs

ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"
ENV PORT=3000

EXPOSE 3000
CMD [ "node","server.js" ]