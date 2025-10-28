# 基于轻量级 Nginx 镜像构建
FROM nginx:alpine

# 删除 Nginx 默认配置，避免冲突
RUN rm /etc/nginx/conf.d/default.conf

# 将自定义代理配置复制到 Nginx 配置目录
COPY nginx.conf /etc/nginx/conf.d/index-tts-proxy.conf

# 暴露 80 端口（若需 HTTPS 可添加 443 端口）
EXPOSE 80

# 启动 Nginx 并保持前台运行（容器存活必需）
CMD ["nginx", "-g", "daemon off;"]