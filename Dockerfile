# ETAPA 1: Construcción (Builder)
FROM node:20-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# IMPORTANTE: Si tienes variables de entorno PÚBLICAS (PUBLIC_...), 
# debes declararlas aquí para que se "cocinen" en el HTML.
ARG PUBLIC_API_URL
ENV PUBLIC_API_URL=$PUBLIC_API_URL

RUN npm run build

# ETAPA 2: Servidor Web (Nginx)
FROM nginx:alpine AS runtime

# Copiamos la configuración de Nginx que creamos
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiamos los archivos estáticos generados por Astro (carpeta dist)
# a la carpeta pública de Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Nginx usa el puerto 80 por defecto
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]