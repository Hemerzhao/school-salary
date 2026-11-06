# 教师端 H5 前端 — uni-app build:h5 产物由 Nginx 托管
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --registry=https://registry.npmmirror.com
COPY . .
RUN npm run build:h5

FROM nginx:alpine
COPY --from=build /app/dist/build/h5 /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
