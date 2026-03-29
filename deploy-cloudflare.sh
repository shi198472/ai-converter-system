#!/bin/bash

# Cloudflare Pages 部署脚本
# 使用方法: ./deploy-cloudflare.sh [环境]
# 环境: preview (预览) | production (生产)

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "命令 $1 未安装，请先安装"
        exit 1
    fi
}

# 检查环境变量
check_env() {
    if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
        log_error "请设置 CLOUDFLARE_API_TOKEN 环境变量"
        log_info "获取方式: https://dash.cloudflare.com/profile/api-tokens"
        exit 1
    fi
    
    if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
        log_error "请设置 CLOUDFLARE_ACCOUNT_ID 环境变量"
        log_info "获取方式: 在 Cloudflare Dashboard 右上角点击你的头像 -> 'My Profile' -> 'API Tokens' 页面"
        exit 1
    fi
}

# 部署函数
deploy() {
    local ENV=$1
    local PROJECT_NAME="ai-converter-system"
    
    log_info "开始部署到 $ENV 环境..."
    
    # 进入前端目录
    cd frontend
    
    # 安装依赖
    log_info "安装依赖..."
    npm ci
    
    # 构建项目
    log_info "构建项目..."
    if [ "$ENV" = "production" ]; then
        npm run build
    else
        npm run build
    fi
    
    # 创建必要的文件
    log_info "创建配置文件..."
    cd dist
    echo "/* /index.html 200" > _redirects
    
    cat > _headers << 'EOF'
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  Cache-Control: public, max-age=3600
EOF
    
    # 返回项目根目录
    cd ../..
    
    # 部署到 Cloudflare Pages
    log_info "部署到 Cloudflare Pages..."
    if [ "$ENV" = "production" ]; then
        npx wrangler pages deploy frontend/dist \
            --project-name="$PROJECT_NAME" \
            --branch=main \
            --env=production
    else
        npx wrangler pages deploy frontend/dist \
            --project-name="$PROJECT_NAME" \
            --branch=main
    fi
    
    log_success "部署完成！"
}

# 设置环境变量函数
setup_env() {
    log_info "设置环境变量..."
    
    # 从文件读取环境变量（如果存在）
    if [ -f ".env.cloudflare" ]; then
        log_info "从 .env.cloudflare 加载环境变量"
        source .env.cloudflare
    fi
    
    # 交互式设置缺失的环境变量
    if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
        read -p "请输入 Cloudflare API Token: " CLOUDFLARE_API_TOKEN
        export CLOUDFLARE_API_TOKEN
    fi
    
    if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
        read -p "请输入 Cloudflare Account ID: " CLOUDFLARE_ACCOUNT_ID
        export CLOUDFLARE_ACCOUNT_ID
    fi
    
    # 保存到文件
    cat > .env.cloudflare << EOF
CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID=$CLOUDFLARE_ACCOUNT_ID
EOF
    chmod 600 .env.cloudflare
    log_success "环境变量已保存到 .env.cloudflare"
}

# 主函数
main() {
    local ENV=${1:-"preview"}
    
    # 检查参数
    if [[ ! "$ENV" =~ ^(preview|production)$ ]]; then
        log_error "无效的环境参数: $ENV"
        log_info "使用方法: $0 [preview|production]"
        exit 1
    fi
    
    log_info "=== AI Converter System Cloudflare Pages 部署 ==="
    log_info "环境: $ENV"
    log_info "项目: ai-converter-system"
    log_info "时间: $(date)"
    
    # 检查必要命令
    check_command "node"
    check_command "npm"
    check_command "npx"
    
    # 检查 Node.js 版本
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    REQUIRED_VERSION="16.0.0"
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
        log_error "Node.js 版本需要 >= $REQUIRED_VERSION，当前版本: $NODE_VERSION"
        exit 1
    fi
    log_info "Node.js 版本: $NODE_VERSION"
    
    # 设置环境变量
    setup_env
    
    # 检查环境变量
    check_env
    
    # 执行部署
    deploy "$ENV"
    
    log_info "=== 部署完成 ==="
    log_info "下一步:"
    log_info "1. 访问 Cloudflare Dashboard 查看部署状态"
    log_info "2. 配置自定义域名（可选）"
    log_info "3. 设置环境变量（如 API 地址）"
    log_info "4. 测试应用功能"
}

# 执行主函数
main "$@"