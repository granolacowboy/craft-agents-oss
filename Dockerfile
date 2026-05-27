# Craft Agent headless server — Bun runtime
# Build context: ./craft-agents-oss

FROM oven/bun:1 AS builder

WORKDIR /app
COPY package.json bun.lock ./
COPY packages/server/package.json packages/server/
COPY packages/server-core/package.json packages/server-core/
COPY packages/shared/package.json packages/shared/
COPY packages/core/package.json packages/core/
COPY packages/session-tools-core/package.json packages/session-tools-core/
COPY packages/session-mcp-server/package.json packages/session-mcp-server/
COPY packages/pi-agent-server/package.json packages/pi-agent-server/
COPY packages/ui/package.json packages/ui/
COPY apps/cli/package.json apps/cli/
COPY apps/electron/package.json apps/electron/
COPY apps/viewer/package.json apps/viewer/

RUN bun install --frozen-lockfile

COPY packages/ packages/
COPY tsconfig.json ./

# ─── Runtime stage ────────────────────────────────────────

FROM oven/bun:1-slim

RUN groupadd --system craft && useradd --system --gid craft craft

WORKDIR /app
COPY --from=builder /app /app

# Craft data directory
RUN mkdir -p /home/craft/.craft-agent && chown -R craft:craft /home/craft

USER craft

ENV CRAFT_RPC_HOST=0.0.0.0
ENV CRAFT_RPC_PORT=9100

EXPOSE 9100

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD bun -e "const ws=new WebSocket('ws://127.0.0.1:9100');ws.onopen=()=>{ws.close();process.exit(0)};ws.onerror=()=>process.exit(1);setTimeout(()=>process.exit(1),5000)"

CMD ["bun", "run", "packages/server/src/index.ts"]
