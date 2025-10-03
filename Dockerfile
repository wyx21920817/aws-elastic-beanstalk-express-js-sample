FROM node:16

WORKDIR /app

COPY package*.json ./
RUN (npm ci --omit=dev || npm install --production) && npm cache clean --force

COPY . .

ENV PORT=8081
EXPOSE 8081

CMD ["npm", "start"]
