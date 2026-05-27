# Craft Agent CLI — Bun runtime, headless client
# Build context: ./craft-agents-oss
# Mirrors the server Dockerfile's 2-stage pattern (same patches: Debian useradd, all 11 manifests, in-Docker frozen install).

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
COPY apps/cli/ apps/cli/
COPY tsconfig.json ./

# ─── Runtime stage ────────────────────────────────────────

FROM oven/bun:1-slim

RUN groupadd --system craft && useradd --system --gid craft craft

WORKDIR /app
COPY --from=builder /app /app

USER craft

ENTRYPOINT ["bun", "run", "apps/cli/src/index.ts"]
CMD ["--help"]
