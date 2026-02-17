FROM node:18

WORKERDIR /app

COPY package*.json ./

COPY..

EXPOSEm 5000

CMD["nmp","start"]