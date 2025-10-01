FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --save
COPY . .
EXPOSE 8080
CMD ["npm", "start"]
