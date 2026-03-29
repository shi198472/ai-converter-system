# Cloudflare Pages 配置指南

## 部署方案

由于项目是前后端分离架构，建议采用以下方案：

### 方案 A: 仅部署前端到 Cloudflare Pages
- **前端**: Cloudflare Pages (静态托管)
- **后端**: 其他服务 (Vercel, Railway, Render 等)

### 方案 B: 全栈部署到 Cloudflare
- **前端**: Cloudflare Pages
- **后端**: Cloudflare Workers (需要重写 Express 后端)

**推荐方案 A**，因为：
1. 前端是纯静态 React 应用
2. 后端可以独立部署，更灵活
3. 维护成本更低

## 前端适配 Cloudflare Pages

### 1. 创建构建配置文件

在 `frontend/` 目录下创建 `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      deployments: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        working-directory: frontend
        run: npm ci
      
      - name: Build
        working-directory: frontend
        run: npm run build
        env:
          CI: false
      
      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: ai-converter-system
          directory: frontend/dist
          gitHubToken: ${{ secrets.GITHUB_TOKEN }}
```

### 2. 创建 Cloudflare Pages 配置文件

在项目根目录创建 `_headers` 文件:

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
```

在项目根目录创建 `_redirects` 文件:

```
/* /index.html 200
```

### 3. 更新前端 API 配置

修改 `frontend/src/services/api.ts`，将 API 地址改为生产环境:

```typescript
// 开发环境
const API_BASE_URL = import.meta.env.DEV 
  ? 'http://localhost:3001' 
  : 'https://your-backend-api.com';

// 或者使用环境变量
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';
```

## 手动部署步骤

### 步骤 1: 安装 Wrangler CLI
```bash
npm install -g wrangler
```

### 步骤 2: 登录 Cloudflare
```bash
wrangler login
```

### 步骤 3: 创建 Pages 项目
```bash
wrangler pages project create ai-converter-system \
  --production-branch=main
```

### 步骤 4: 构建前端
```bash
cd frontend
npm install
npm run build
```

### 步骤 5: 部署到 Cloudflare Pages
```bash
wrangler pages deploy ./dist \
  --project-name=ai-converter-system \
  --branch=main
```

## 环境变量配置

### GitHub Secrets 需要设置:
1. `CLOUDFLARE_API_TOKEN` - Cloudflare API Token
2. `CLOUDFLARE_ACCOUNT_ID` - Cloudflare 账户 ID

### Cloudflare Pages 环境变量:
在 Cloudflare Dashboard 中设置:
- `NODE_VERSION`: 18
- `VITE_API_URL`: 你的后端 API 地址

## 自定义域名配置

### 1. 添加自定义域名
在 Cloudflare Pages 项目设置中:
1. 点击 "Custom domains"
2. 输入你的域名 (如: converter.yourdomain.com)
3. 按照提示配置 DNS

### 2. DNS 配置示例
```
CNAME converter yourdomain.com.cloudflarepages.com
```

## 监控和日志

### 访问日志
在 Cloudflare Pages Dashboard 中:
- 查看部署历史
- 查看构建日志
- 查看访问统计

### 错误监控
建议集成:
- Sentry (错误跟踪)
- Google Analytics (访问统计)
- Cloudflare Analytics (内置)

## 故障排除

### 常见问题 1: 构建失败
**症状**: npm run build 失败
**解决**: 
- 检查 Node.js 版本 (需要 16+)
- 检查依赖冲突
- 查看构建日志

### 常见问题 2: 页面空白
**症状**: 部署成功但页面空白
**解决**:
- 检查 `_redirects` 文件
- 检查控制台错误
- 验证 API 连接

### 常见问题 3: API 跨域错误
**症状**: CORS 错误
**解决**:
- 后端配置 CORS
- 使用 Cloudflare Workers 代理
- 配置正确的 API 地址

## 性能优化建议

### 1. 缓存策略
```nginx
# 在 _headers 文件中添加
/*
  Cache-Control: public, max-age=3600
  CDN-Cache-Control: public, max-age=86400
```

### 2. 图片优化
- 使用 WebP 格式
- 实现懒加载
- 使用 Cloudflare Images

### 3. 代码分割
- React.lazy() 动态导入
- 路由级代码分割
- 第三方库单独打包

## 安全建议

### 1. 内容安全策略 (CSP)
在 `_headers` 中添加:
```
/*
  Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';
```

### 2. HTTPS 强制
Cloudflare Pages 自动启用 HTTPS

### 3. 访问控制
- 设置环境变量保护敏感信息
- 使用 Cloudflare Access 进行身份验证
- 实现 API 密钥验证

## 备份和恢复

### 1. 代码备份
- GitHub 自动备份
- 定期本地备份

### 2. 数据备份
- 数据库定期备份
- 配置文件版本控制

### 3. 灾难恢复
- 多区域部署
- 备份部署流程文档
- 紧急联系人列表