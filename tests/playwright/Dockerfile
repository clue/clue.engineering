FROM mcr.microsoft.com/playwright:v1.63.0-noble
WORKDIR /app
# install @playwright/test matching the base image version above
RUN npm install @playwright/test@$(node -p "JSON.parse(fs.readFileSync('/ms-playwright/.docker-info')).driverVersion")
COPY . .
CMD ["npx", "playwright", "test"]
