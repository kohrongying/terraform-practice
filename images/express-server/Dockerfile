FROM node:12

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080

ARG BASE_URL='localhost'
ENV BASE_URL="${BASE_URL}"

ARG BASE_URL_PORT=5000
ENV BASE_URL_PORT=${BASE_URL_PORT}

CMD ["node", "server.js"]