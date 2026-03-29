#!/bin/bash

# 构建和准备部署脚本
# 只构建项目，然后指导手动上传到 Cloudflare Pages

set -e

echo "🚀 AI Converter System 构建和部署准备"
echo "======================================"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 检查 Node.js
echo -e "${BLUE}🔍 检查环境...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js 未安装${NC}"
    echo "请先安装 Node.js: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}✅ Node.js 版本: $NODE_VERSION${NC}"

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm 未安装${NC}"
    exit 1
fi

# 进入前端目录
cd frontend

# 清理之前的构建
echo -e "${BLUE}🧹 清理旧构建...${NC}"
rm -rf dist 2>/dev/null || true

# 安装依赖
echo -e "${BLUE}📦 安装依赖...${NC}"
if [ -f "package-lock.json" ]; then
    npm ci --silent
else
    npm install --silent
fi

echo -e "${GREEN}✅ 依赖安装完成${NC}"

# 构建项目
echo -e "${BLUE}🔨 构建项目...${NC}"
npm run build --silent

# 检查构建结果
if [ ! -d "dist" ]; then
    echo -e "${RED}❌ 构建失败，dist 目录未生成${NC}"
    exit 1
fi

cd dist

# 创建必要的部署文件
echo -e "${BLUE}📝 创建部署文件...${NC}"
echo "/* /index.html 200" > _redirects

cat > _headers << 'EOF'
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
EOF

# 统计文件
FILE_COUNT=$(find . -type f | wc -l)
TOTAL_SIZE=$(du -sh . | cut -f1)

echo -e "${GREEN}✅ 构建完成！${NC}"
echo ""
echo -e "${BLUE}📊 构建统计:${NC}"
echo "  文件数量: $FILE_COUNT"
echo "  总大小: $TOTAL_SIZE"
echo "  主要文件:"
ls -la | grep -E "\.(html|js|css)$" | head -10

# 返回项目根目录
cd ../..

echo ""
echo -e "${YELLOW}🎯 下一步: 手动上传到 Cloudflare Pages${NC}"
echo "================================================"
echo ""
echo "1. ${GREEN}登录 Cloudflare Dashboard${NC}"
echo "   访问: https://dash.cloudflare.com/"
echo ""
echo "2. ${GREEN}创建 Pages 项目${NC}"
echo "   • 点击左侧 'Workers & Pages'"
echo "   • 点击 'Create application' → 'Pages'"
echo "   • 选择 'Direct upload' (直接上传)"
echo ""
echo "3. ${GREEN}配置项目${NC}"
echo "   • 项目名称: ai-converter-system"
echo "   • 生产分支: main"
echo "   • 构建命令: (留空)"
echo "   • 构建输出目录: (留空)"
echo ""
echo "4. ${GREEN}上传文件${NC}"
echo "   • 点击 'Upload assets'"
echo "   • 选择目录: $(pwd)/frontend/dist"
echo "   • 点击 'Save and Deploy'"
echo ""
echo "5. ${GREEN}等待部署完成${NC}"
echo "   • 部署需要 1-2 分钟"
echo "   • 完成后访问: https://ai-converter-system.pages.dev"
echo ""
echo -e "${BLUE}💡 提示:${NC}"
echo "• 确保 frontend/dist 目录包含 index.html"
echo "• 如果上传失败，可以打包成 ZIP 再上传"
echo "• 部署完成后测试网站功能"
echo ""
echo -e "${GREEN}✅ 构建文件已准备好！${NC}"
echo "位置: $(pwd)/frontend/dist"
echo ""
echo -e "${YELLOW}📦 可选: 创建 ZIP 包便于上传${NC}"
echo "运行: zip -r deployment.zip frontend/dist"
echo "然后上传 deployment.zip 文件"

# 创建 ZIP 包的选项
echo ""
read -p "是否创建 ZIP 包? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}📦 创建 ZIP 包...${NC}"
    zip -r deployment.zip frontend/dist > /dev/null 2>&1
    ZIP_SIZE=$(du -h deployment.zip | cut -f1)
    echo -e "${GREEN}✅ ZIP 包创建完成: deployment.zip ($ZIP_SIZE)${NC}"
fi

echo ""
echo -e "${BLUE}🚀 开始手动上传吧！${NC}"
echo "完成后访问: https://ai-converter-system.pages.dev"