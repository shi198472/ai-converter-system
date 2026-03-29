#!/bin/bash

# 直接部署脚本 - 绕过所有复杂配置
# 使用 curl 直接与 Cloudflare API 交互

set -e

echo "🚀 Cloudflare Pages 直接部署脚本"
echo "=================================="

# 检查必要的工具
command -v curl >/dev/null 2>&1 || { echo "❌ 需要安装 curl"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "❌ 需要安装 jq"; exit 1; }

# 配置
ACCOUNT_ID="907dc1ca42c6f0e75b5ea92bb02c8aa6"
PROJECT_NAME="ai-converter-system"

# 获取 Token
read -p "请输入 Cloudflare API Token: " API_TOKEN
echo ""

if [ -z "$API_TOKEN" ]; then
    echo "❌ Token 不能为空"
    exit 1
fi

# 验证 Token
echo "🔍 验证 Token..."
VERIFY_RESPONSE=$(curl -s -X GET \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/user/tokens/verify")

if echo "$VERIFY_RESPONSE" | jq -e '.success == true' >/dev/null 2>&1; then
    echo "✅ Token 验证成功"
    TOKEN_ID=$(echo "$VERIFY_RESPONSE" | jq -r '.result.id')
    echo "   Token ID: $TOKEN_ID"
else
    echo "❌ Token 验证失败"
    ERROR_MSG=$(echo "$VERIFY_RESPONSE" | jq -r '.errors[0].message // "未知错误"')
    echo "   错误: $ERROR_MSG"
    exit 1
fi

# 检查账户
echo "🔍 检查账户..."
ACCOUNT_RESPONSE=$(curl -s -X GET \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID")

if echo "$ACCOUNT_RESPONSE" | jq -e '.success == true' >/dev/null 2>&1; then
    ACCOUNT_NAME=$(echo "$ACCOUNT_RESPONSE" | jq -r '.result.name')
    echo "✅ 账户访问成功: $ACCOUNT_NAME"
else
    echo "❌ 无法访问账户"
    exit 1
fi

# 构建前端
echo "🔨 构建前端项目..."
cd frontend

# 清理之前的构建
rm -rf dist 2>/dev/null || true

# 安装依赖
echo "  安装依赖..."
npm ci --silent 2>&1 || npm install --silent 2>&1

# 构建
echo "  构建项目..."
npm run build --silent 2>&1

if [ ! -d "dist" ]; then
    echo "❌ 构建失败，dist 目录未生成"
    exit 1
fi

cd dist

# 创建必要的文件
echo "/* /index.html 200" > _redirects

cat > _headers << 'EOF'
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
EOF

echo "✅ 前端构建完成"
cd ../..

# 创建部署包
echo "📦 创建部署包..."
DEPLOY_DIR="frontend/dist"
ZIP_FILE="deploy-$(date +%Y%m%d-%H%M%S).zip"

cd "$DEPLOY_DIR"
zip -r "../../$ZIP_FILE" . > /dev/null 2>&1
cd - > /dev/null

echo "✅ 部署包创建: $ZIP_FILE"

# 检查项目是否存在
echo "🔍 检查 Pages 项目..."
PROJECT_RESPONSE=$(curl -s -X GET \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME")

# 如果项目不存在，创建它
if echo "$PROJECT_RESPONSE" | jq -e '.errors[0].code == 10007' >/dev/null 2>&1; then
    echo "📝 创建 Pages 项目..."
    CREATE_RESPONSE=$(curl -s -X POST \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"name\":\"$PROJECT_NAME\",\"production_branch\":\"main\"}" \
      "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects")
    
    if echo "$CREATE_RESPONSE" | jq -e '.success == true' >/dev/null 2>&1; then
        echo "✅ 项目创建成功"
    else
        echo "❌ 项目创建失败"
        echo "$CREATE_RESPONSE" | jq .
        exit 1
    fi
else
    echo "✅ 项目已存在"
fi

# 获取上传 URL
echo "📤 获取上传 URL..."
UPLOAD_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/upload")

UPLOAD_URL=$(echo "$UPLOAD_RESPONSE" | jq -r '.result.url // empty')

if [ -z "$UPLOAD_URL" ]; then
    echo "❌ 获取上传 URL 失败"
    echo "$UPLOAD_RESPONSE" | jq .
    exit 1
fi

echo "✅ 上传 URL 获取成功"

# 上传文件
echo "⬆️  上传部署包..."
UPLOAD_RESULT=$(curl -s -X PUT \
  -H "Content-Type: application/zip" \
  --data-binary @"$ZIP_FILE" \
  "$UPLOAD_URL")

# 清理临时文件
rm -f "$ZIP_FILE"

# 触发部署
echo "🚀 触发部署..."
DEPLOY_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"branch\":\"main\"}" \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/deployments")

if echo "$DEPLOY_RESPONSE" | jq -e '.success == true' >/dev/null 2>&1; then
    DEPLOYMENT_ID=$(echo "$DEPLOY_RESPONSE" | jq -r '.result.id')
    DEPLOYMENT_URL=$(echo "$DEPLOY_RESPONSE" | jq -r '.result.url')
    
    echo ""
    echo "🎉 部署成功！"
    echo "=================================="
    echo "🔗 访问地址: https://$PROJECT_NAME.pages.dev"
    echo "📊 部署 ID: $DEPLOYMENT_ID"
    echo "🌐 部署 URL: $DEPLOYMENT_URL"
    echo ""
    echo "📋 下一步:"
    echo "1. 等待 1-2 分钟让部署生效"
    echo "2. 访问 https://$PROJECT_NAME.pages.dev 测试"
    echo "3. 在 Cloudflare Dashboard 查看部署状态"
else
    echo "❌ 部署失败"
    echo "$DEPLOY_RESPONSE" | jq .
    exit 1
fi