# 🚀 一键部署到 Cloudflare Pages - 立即开始

## 使用你的 Token 和 Account ID 直接部署

### 步骤 1: 打开 GitHub Actions 页面
**点击这个链接**: https://github.com/shi198472/ai-converter-system/actions

### 步骤 2: 找到专门的工作流
在左侧找到 **"Deploy with Your Cloudflare Token"**，点击它。

### 步骤 3: 点击运行按钮
点击蓝色的 **"Run workflow"** 按钮。

### 步骤 4: 确认部署
你会看到一个下拉菜单，选择：
```
是的，使用 cfat_FcDmYMMMdVAdsqWdxlvIwKjc392TZAR1m0ZGZUV71422fd1a
```

### 步骤 5: 点击运行
点击绿色的 **"Run workflow"** 按钮。

## ⏱️ 部署过程

部署会自动进行以下步骤：

1. ✅ **代码检出** - 获取最新代码
2. ✅ **Node.js 环境** - 设置开发环境
3. ✅ **安装依赖** - 安装所有需要的包
4. ✅ **构建项目** - 编译前端应用
5. ✅ **创建部署文件** - 准备上传
6. ✅ **测试 Cloudflare API** - 验证连接
7. ✅ **部署到 Cloudflare Pages** - 上传并发布
8. ✅ **显示部署状态** - 提供访问链接

## 🌐 访问你的网站

部署完成后，访问：
```
https://ai-converter-system.pages.dev
```

## 📊 查看部署状态

### 在 GitHub 上查看：
1. 回到 Actions 页面
2. 点击运行中的工作流
3. 查看每个步骤的日志
4. 查找部署 URL

### 在 Cloudflare 上查看：
1. 登录 Cloudflare Dashboard
2. 进入 Workers & Pages
3. 查看 ai-converter-system 项目
4. 查看部署历史和访问统计

## 🚨 如果部署失败

### 常见问题 1: Token 无效
**症状**: "Authentication error" 或 "Invalid API Token"
**解决**: 
- Token 可能已过期
- 需要重新生成 Token
- 使用 "Edit Cloudflare Workers" 模板

### 常见问题 2: 权限不足
**症状**: "Unauthorized" 或 "Forbidden"
**解决**:
- Token 需要 `Account:Cloudflare Pages:Edit` 权限
- 在创建 Token 时选择正确的权限

### 常见问题 3: 构建失败
**症状**: "npm run build failed"
**解决**:
- 查看构建日志中的具体错误
- 检查 Node.js 版本兼容性

## 🔧 备选方案

如果一键部署不工作，可以使用：

### 方案 A: 手动上传到 Cloudflare Dashboard
1. 运行构建脚本: `./build-and-prepare.sh`
2. 登录 Cloudflare Dashboard
3. 手动上传 `frontend/dist` 目录

### 方案 B: 使用 Wrangler CLI
```bash
# 安装 Wrangler
npm install -g wrangler

# 登录
wrangler login

# 部署
wrangler pages deploy frontend/dist --project-name=ai-converter-system
```

### 方案 C: 获取新的 API Token
1. 访问: https://dash.cloudflare.com/profile/api-tokens
2. 使用 "Edit Cloudflare Workers" 模板
3. 确保有 `Account:Cloudflare Pages:Edit` 权限
4. 使用新 Token 重新部署

## 📱 快速链接

- **一键部署**: https://github.com/shi198472/ai-converter-system/actions/workflows/deploy-with-your-token.yml
- **GitHub Actions**: https://github.com/shi198472/ai-converter-system/actions
- **Cloudflare Pages**: https://dash.cloudflare.com/907dc1ca42c6f0e75b5ea92bb02c8aa6/workers-and-pages
- **网站地址**: https://ai-converter-system.pages.dev

## ✅ 验证部署成功

部署完成后，请验证：

1. ✅ 可以访问 https://ai-converter-system.pages.dev
2. ✅ 页面正常加载，无错误
3. ✅ 输入框可以输入文本
4. ✅ 按钮可以点击
5. ✅ 响应式设计正常

## 📞 获取帮助

如果遇到任何问题：
1. **截图错误信息**
2. **提供工作流运行 ID**
3. **描述具体问题**

我会帮你分析并解决。

---

**现在就开始部署！**

点击这个链接开始一键部署：
https://github.com/shi198472/ai-converter-system/actions/workflows/deploy-with-your-token.yml

**预计时间**: 3-5分钟  
**难度**: ⭐☆☆☆☆ (点点按钮就行)

**祝你部署顺利！完成后告诉我结果。** 🚀