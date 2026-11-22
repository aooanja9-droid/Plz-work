FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Luvit toolchain (luvit, lit, luvi) into /app
RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh \
 && ./lit install SinisterRectus/discordia

COPY . .

CMD ["./luvit", "bot.lua"]
