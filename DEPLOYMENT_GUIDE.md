# AI Converter System 部署指南

## 🚀 部署选项

### 选项 1: Cloudflare Pages (推荐)
- **类型**: 静态网站托管
- **费用**: 免费
- **特点**: 全球 CDN、自动 HTTPS、Git 集成
- **适合**: 前端部署

### 选项 2: Vercel
- **类型**: 全栈平台
- **费用**: 免费
- **特点**: 自动部署、Serverless Functions
- **适合**: 前后端一体部署

### 选项 3: Railway / Render
- **类型**: 应用托管平台
- **费用**: 免费额度
- **特点**: 数据库集成、自动缩放
- **适合**: 后端部署

## 📋 Cloudflare Pages 部署步骤

### 步骤 1: 准备环境

#### 1.1 获取 Cloudflare API Token
1. 登录 Cloudflare Dashboard: https://dash.cloudflare.com/
2. 点击右上角头像 → "My Profile"
3. 选择 "API Tokens" 标签页
4. 点击 "Create Token"
5. 选择模板 "Edit Cloudflare Workers"
6. 添加权限:
   - `Account:Cloudflare Pages:Edit`
   - `Zone:Page Rules:Edit` (如果需要自定义域名)
7. 生成并复制 Token

#### 1.2 获取 Account ID
1. 在 Cloudflare Dashboard 首页
2. 查看右侧边栏，找到 "Account ID"
3. 复制 ID (格式: 32位十六进制字符串)

#### 1.3 配置本地环境
```bash
# 克隆项目
git clone https://github.com/shi198472/ai-converter-system.git
cd ai-converter-system

# 复制环境变量文件
cp .env.cloudflare.example .env.cloudflare

# 编辑 .env.cloudflare 文件
# 填写你的 Cloudflare API Token 和 Account ID
```

### 步骤 2: 手动部署

#### 2.1 使用部署脚本
```bash
# 给脚本执行权限
chmod +x deploy-cloudflare.sh

# 预览环境部署
./deploy-cloudflare.sh preview

# 生产环境部署
./deploy-cloudflare.sh production
```

#### 2.2 使用 Wrangler CLI
```bash
# 安装 Wrangler
npm install -g wrangler

# 登录 Cloudflare
wrangler login

# 创建 Pages 项目
wrangler pages project create ai-converter-system --production-branch=main

# 部署前端
cd frontend
npm run build
wrangler pages deploy ./dist --project-name=ai-converter-system
```

### 步骤 3: 自动部署 (GitHub Actions)

#### 3.1 配置 GitHub Secrets
在 GitHub 仓库设置中添加:
1. `CLOUDFLARE_API_TOKEN` - Cloudflare API Token
2. `CLOUDFLARE_ACCOUNT_ID` - Cloudflare Account ID
3. `VITE_API_URL` - 后端 API 地址 (可选)

#### 3.2 触发自动部署
- 推送到 `main` 分支自动触发部署
- 创建 Pull Request 触发预览部署
- 手动在 GitHub Actions 页面触发

### 步骤 4: 配置自定义域名 (可选)

#### 4.1 在 Cloudflare Pages 中配置
1. 进入 Pages 项目
2. 点击 "Custom domains"
3. 输入你的域名
4. 按照提示配置 DNS

#### 4.2 DNS 配置示例
```
# Cloudflare DNS 配置
CNAME converter yourdomain.com.cloudflarepages.com

# 或者使用 A 记录
A converter 104.16.246.78
A converter 104.16.247.78
```

## 🔧 后端部署

### 方案 A: Vercel (推荐)
```bash
# 安装 Vercel CLI
npm i -g vercel

# 部署后端
cd backend
vercel

# 设置环境变量
vercel env add OPENAI_API_KEY
```

### 方案 B: Railway
```bash
# 安装 Railway CLI
npm i -g @railway/cli

# 部署
railway up

# 设置环境变量
railway variables set OPENAI_API_KEY=your_key
```

### 方案 C: Render
1. 访问 https://render.com/
2. 点击 "New +" → "Web Service"
3. 连接 GitHub 仓库
4. 配置:
   - Build Command: `npm install && npm run build`
   - Start Command: `npm start`
   - Environment Variables: 添加 `OPENAI_API_KEY`

## 🌐 环境变量配置

### 前端环境变量
```env
# .env.production
VITE_API_URL=https://your-backend-api.com
VITE_APP_NAME=AI Converter System
VITE_ENABLE_ANALYTICS=true
```

### 后端环境变量
```env
# backend/.env
PORT=3001
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
NODE_ENV=production
CORS_ORIGIN=https://your-frontend-domain.com
```

## 🧪 测试部署

### 1. 健康检查
```bash
# 前端健康检查
curl https://ai-converter-system.pages.dev/

# API 健康检查
curl https://your-backend-api.com/api/health
```

### 2. 功能测试
1. 访问部署的前端地址
2. 输入测试任务: "学习Python编程"
3. 验证 AI 分解功能
4. 测试步骤勾选功能
5. 验证历史记录

### 3. 性能测试
```bash
# 使用 Lighthouse 测试
npx lighthouse https://your-domain.com --view

# 使用 PageSpeed Insights
# 访问: https://pagespeed.web.dev/
```

## 📊 监控和维护

### 1. Cloudflare Analytics
- 访问 Pages 项目 Dashboard
- 查看访问统计
- 查看构建历史
- 查看错误日志

### 2. 错误监控
建议集成:
- **Sentry**: 错误跟踪
- **Google Analytics**: 用户行为分析
- **Cloudflare Web Analytics**: 内置分析

### 3. 定期维护
- 每月更新依赖包
- 检查安全漏洞
- 备份重要数据
- 更新部署文档

## 🔄 持续集成/持续部署 (CI/CD)

### GitHub Actions 工作流
已配置的工作流:
1. **自动测试**: 代码提交时运行测试
2. **自动构建**: 创建 Pull Request 时构建预览
3. **自动部署**: 推送到 main 分支时部署到生产环境

### 手动触发部署
```bash
# 使用 GitHub CLI
gh workflow run deploy-to-cloudflare-pages.yml

# 或通过 GitHub Web 界面
# Actions → Deploy to Cloudflare Pages → Run workflow
```

## 🚨 故障排除

### 常见问题 1: 构建失败
**错误**: `npm run build` 失败
**解决**:
```bash
# 清理缓存
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# 检查 Node.js 版本
node --version  # 需要 >= 16.0.0
```

### 常见问题 2: 页面空白
**错误**: 部署成功但页面空白
**解决**:
1. 检查浏览器控制台错误
2. 验证 `_redirects` 文件
3. 检查 API 连接
4. 查看构建日志

### 常见问题 3: CORS 错误
**错误**: `Access-Control-Allow-Origin`
**解决**:
1. 后端配置 CORS
```javascript
app.use(cors({
  origin: ['https://your-frontend-domain.com'],
  credentials: true
}));
```
2. 或使用 Cloudflare Workers 代理

### 常见问题 4: 环境变量未生效
**错误**: 环境变量在构建时未注入
**解决**:
1. 检查 GitHub Secrets 配置
2. 验证环境变量名称
3. 重新触发部署

## 📈 性能优化

### 1. 前端优化
- 启用代码分割
- 图片优化 (WebP 格式)
- 启用 Gzip/Brotli 压缩
- 使用 CDN 缓存

### 2. 后端优化
- 启用响应缓存
- 数据库连接池
- API 限流
- 错误重试机制

### 3. Cloudflare 优化
- 启用 Argo Smart Routing
- 配置缓存规则
- 启用 Brotli 压缩
- 配置防火墙规则

## 🔒 安全配置

### 1. 前端安全
- 启用 HTTPS
- 设置安全头
- 实现 CSP
- 防止 XSS 攻击

### 2. 后端安全
- API 密钥保护
- 输入验证
- SQL 注入防护
- 速率限制

### 3. 部署安全
- 使用环境变量
- 定期轮换密钥
- 访问日志监控
- 安全扫描

## 📞 支持

### 遇到问题?
1. 查看部署日志
2. 检查 GitHub Actions 状态
3. 查看 Cloudflare Pages 构建日志
4. 在 GitHub Issues 中提问

### 紧急恢复
1. 回滚到上一个版本
2. 手动部署稳定版本
3. 联系技术支持

---

**最后更新**: 2024年3月29日  
**部署状态**: ✅ 生产就绪  
**支持渠道**: GitHub Issues