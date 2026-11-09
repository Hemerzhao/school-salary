# 单服务镜像：同时提供管理端页面、教师端页面和 API
# 构建上下文为仓库根目录（Zeabur / Render / Koyeb 等平台通用）

FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY backend/pom.xml .
RUN mvn dependency:go-offline -B
COPY backend/src ./src
RUN mvn clean package -DskipTests -B

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# 免费实例内存较小，限制堆大小避免 OOM
ENV JAVA_OPTS="-Xmx300m -Xss512k -XX:+UseSerialGC"

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
