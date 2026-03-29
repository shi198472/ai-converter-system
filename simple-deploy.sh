#!/bin/bash

# Cloudflare Pages 简化部署脚本
# 使用环境变量直接部署

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查命令
check_command() {
    if ! command -v $1 &> /dev/null; then
        error "命令 $1 未安装"
        return 1
    fi
    return 0
}

# 加载环境变量
load_env() {
    if [ -f ".env.cloudflare" ]; then
        log "加载环境变量..."
        source .env.cloudflare
    else
        error "环境变量文件 .env.cloudflare 不存在"
        exit 1
    fi
    
    # 检查必要的环境变量
    if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
        error "CLOUDFLARE_API_TOKEN 未设置"
        exit 1
    fi
    
    if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
        error "CLOUDFLARE_ACCOUNT_ID 未设置"
        exit 1
    fi
    
    PROJECT_NAME=${PROJECT_NAME:-"ai-converter-system"}
    success "环境变量加载成功"
}

# 测试 Cloudflare API
test_api() {
    log "测试 Cloudflare API 连接..."
    
    RESPONSE=$(curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/user/tokens/verify")
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        success "API Token 验证成功"
        
        # 提取 Token 信息
        TOKEN_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        EXPIRES=$(echo "$RESPONSE" | grep -o '"expires_on":"[^"]*"' | cut -d'"' -f4)
        
        log "Token ID: $TOKEN_ID"
        log "有效期至: $EXPIRES"
        return 0
    else
        error "API Token 验证失败"
        
        # 尝试其他验证方式
        log "尝试其他验证方式..."
        
        # 方法2: 直接测试账户访问
        RESPONSE2=$(curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" \
            "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID")
        
        if echo "$RESPONSE2" | grep -q '"success":true'; then
            success "通过账户访问验证成功"
            return 0
        else
            error "所有验证方式都失败"
            log "响应1: $RESPONSE"
            log "响应2: $RESPONSE2"
            return 1
        fi
    fi
}

# 安装 Wrangler
install_wrangler() {
    log "检查 Wrangler CLI..."
    
    if check_command "wrangler"; then
        WRANGLER_VERSION=$(wrangler --version 2>/dev/null || echo "unknown")
        success "Wrangler 已安装: $WRANGLER_VERSION"
        return 0
    fi
    
    log "安装 Wrangler CLI..."
    
    if check_command "npm"; then
        npm install -g wrangler 2>&1 | while read line; do
            log "npm: $line"
        done
        
        if check_command "wrangler"; then
            success "Wrangler 安装成功"
            return 0
        else
            error "Wrangler 安装失败"
            return 1
        fi
    else
        error "npm 未安装，无法安装 Wrangler"
        return 1
    fi
}

# 构建前端
build_frontend() {
    log "构建前端项目..."
    
    if [ ! -d "frontend" ]; then
        error "前端目录 'frontend' 不存在"
        return 1
    fi
    
    cd frontend
    
    # 安装依赖
    log "安装依赖..."
    if [ -f "package-lock.json" ]; then
        npm ci 2>&1 | while read line; do
            log "npm: $line"
        done
    else
        npm install 2>&1 | while read line; do
            log "npm: $line"
        done
    fi
    
    # 构建项目
    log "构建项目..."
    npm run build 2>&1 | while read line; do
        log "build: $line"
    done
    
    # 检查构建结果
    if [ ! -d "dist" ]; then
        error "构建失败，dist 目录未生成"
        cd ..
        return 1
    fi
    
    cd dist
    
    # 创建部署文件
    log "创建部署文件..."
    echo "/* /index.html 200" > _redirects
    
    cat > _headers << 'EOF'
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  Cache-Control: public, max-age=3600
EOF
    
    success "前端构建成功"
    cd ../..
    return 0
}

# 直接使用 API 部署
deploy_via_api() {
    log "通过 API 直接部署..."
    
    # 首先检查项目是否存在
    log "检查项目状态..."
    
    PROJECTS_RESPONSE=$(curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME")
    
    # 如果项目不存在，先创建
    if echo "$PROJECTS_RESPONSE" | grep -q '"code":10007'; then
        log "项目不存在，正在创建..."
        
        CREATE_RESPONSE=$(curl -s -X POST \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"name\":\"$PROJECT_NAME\",\"production_branch\":\"main\"}" \
            "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects")
        
        if echo "$CREATE_RESPONSE" | grep -q '"success":true'; then
            success "项目创建成功"
        else
            error "项目创建失败"
            log "响应: $CREATE_RESPONSE"
            return 1
        fi
    else
        success "项目已存在"
    fi
    
    # 部署项目
    log "开始部署..."
    
    # 创建部署包
    DEPLOY_DIR="frontend/dist"
    if [ ! -d "$DEPLOY_DIR" ]; then
        error "部署目录不存在: $DEPLOY_DIR"
        return 1
    fi
    
    # 创建临时 zip 文件
    TEMP_ZIP=$(mktemp).zip
    cd "$DEPLOY_DIR"
    zip -r "$TEMP_ZIP" . > /dev/null 2>&1
    cd - > /dev/null
    
    # 上传并部署
    log "上传部署包..."
    
    # 获取上传 URL
    UPLOAD_RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME/upload")
    
    UPLOAD_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$UPLOAD_URL" ]; then
        error "获取上传 URL 失败"
        log "响应: $UPLOAD_RESPONSE"
        rm -f "$TEMP_ZIP"
        return 1
    fi
    
    # 上传文件
    UPLOAD_RESULT=$(curl -s -X PUT \
        -H "Content-Type: application/zip" \
        --data-binary @"$TEMP_ZIP" \
        "$UPLOAD_URL")
    
    # 清理临时文件
    rm -f "$TEMP_ZIP"
    
    # 触发部署
    log "触发部署..."
    DEPLOY_RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"branch\":\"main\",\"skip_duplicate\":true}" \
        "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME/deployments")
    
    if echo "$DEPLOY_RESPONSE" | grep -q '"success":true'; then
        DEPLOYMENT_ID=$(echo "$DEPLOY_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        DEPLOYMENT_URL=$(echo "$DEPLOY_RESPONSE" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
        
        success "部署触发成功！"
        log "部署 ID: $DEPLOYMENT_ID"
        log "访问地址: https://$PROJECT_NAME.pages.dev"
        log "部署详情: https://dash.cloudflare.com/$CLOUDFLARE_ACCOUNT_ID/pages/view/$PROJECT_NAME/$DEPLOYMENT_ID"
        
        return 0
    else
        error "部署触发失败"
        log "响应: $DEPLOY_RESPONSE"
        return 1
    fi
}

# 主函数
main() {
    echo -e "${BLUE}=== Cloudflare Pages 自动化部署 ===${NC}"
    echo -e "${BLUE}项目: ai-converter-system${NC}"
    echo -e "${BLUE}时间: $(date)${NC}"
    echo ""
    
    # 加载环境变量
    load_env
    
    # 测试 API
    if ! test_api; then
        error "API 测试失败，请检查 Token 和网络"
        exit 1
    fi
    
    # 安装 Wrangler
    if ! install_wrangler; then
        warning "Wrangler 安装失败，尝试直接 API 部署"
    fi
    
    # 构建前端
    if ! build_frontend; then
        error "前端构建失败"
        exit 1
    fi
    
    # 部署
    log "开始部署流程..."
    
    # 尝试使用 Wrangler 部署
    if command -v wrangler &> /dev/null; then
        log "使用 Wrangler 部署..."
        
        # 登录（使用环境变量）
        export CLOUDFLARE_API_TOKEN
        export CLOUDFLARE_ACCOUNT_ID
        
        # 部署
        DEPLOY_OUTPUT=$(wrangler pages deploy frontend/dist \
            --project-name="$PROJECT_NAME" \
            --branch=main 2>&1)
        
        if [ $? -eq 0 ]; then
            success "Wrangler 部署成功！"
            echo "$DEPLOY_OUTPUT"
            
            # 提取 URL
            echo "$DEPLOY_OUTPUT" | grep -o 'https://[^ ]*\.pages\.dev' | head -1 | while read url; do
                success "访问地址: $url"
            done
            
            exit 0
        else
            warning "Wrangler 部署失败，尝试 API 部署"
            echo "$DEPLOY_OUTPUT"
        fi
    fi
    
    # 使用 API 部署
    if deploy_via_api; then
        success "部署完成！"
    else
        error "所有部署方式都失败"
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}=== 部署完成 ===${NC}"
    echo -e "${BLUE}下一步:${NC}"
    echo "1. 访问 https://$PROJECT_NAME.pages.dev"
    echo "2. 在 Cloudflare Dashboard 查看部署状态"
    echo "3. 测试应用功能"
    echo "4. 配置自定义域名（可选）"
}

# 运行主函数
main "$@"