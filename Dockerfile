FROM node:22-alpine

WORKDIR /app

COPY app/package*.json ./

RUN npm install

COPY app/ .

RUN apk add --no-cache curl

EXPOSE 5000

HEALTHCHECK --interval=10s \
            --timeout=5s \
            --start-period=10s \
            --retries=3 \
            CMD curl -f http://localhost:5000/api/health || exit 1

CMD ["npm", "start"]