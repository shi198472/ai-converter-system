# 🔑 获取有效的 Cloudflare API Token - 详细步骤

## 为什么需要新 Token？

当前的 Token `cfat_FcDmYMMMdVAdsqWdxlvIwKjc392TZAR1m0ZGZUV71422fd1a` 无效，导致 "Authentication error"。

## 🎯 获取正确 Token 的步骤

### 第 1 步: 打开 Cloudflare Dashboard
1. **访问**: https://dash.cloudflare.com/
2. **登录**你的账户

### 第 2 步: 进入 API Tokens 页面
1. 点击右上角你的**头像**
2. 选择 **"My Profile"** (我的资料)
3. 点击左侧的 **"API Tokens"** (API 令牌)

### 第 3 步: 创建新 Token
1. 点击蓝色的 **"Create Token"** (创建令牌) 按钮

### 第 4 步: 选择正确的模板
**重要**: 选择 **"Edit Cloudflare Workers"** 模板

不要选择其他模板，这个模板包含 Pages 部署所需的权限。

### 第 5 步: 配置权限
确保勾选以下权限：

#### Account Resources (账户资源)
- ✅ `Account:Cloudflare Pages:Edit` **(必须)**
- ✅ `Account:Workers Scripts:Edit` (推荐)

#### Zone Resources (区域资源)
- 选择 **"All zones"** (所有区域)

### 第 6 步: 设置 Token 详情
1. **Token name** (令牌名称): `ai-converter-system-deployment`
2. **Client IP Address Filtering** (客户端 IP 地址过滤): 留空
3. **TTL** (有效期): 选择 **"Custom"** → 设置为 **90天**

### 第 7 步: 创建并复制 Token
1. 点击 **"Continue to summary"** (继续到摘要)
2. 检查配置是否正确
3. 点击 **"Create Token"** (创建令牌)
4. **立即复制生成的 Token** (只显示一次！)

## 🧪 验证新 Token 是否有效

### 方法 A: 使用命令行验证
```bash
# 替换 YOUR_NEW_TOKEN 为你的新 Token
curl -H "Authorization: Bearer YOUR_NEW_TOKEN" \
  https://api.cloudflare.com/client/v4/user/tokens/verify
```

应该返回 `"success": true`

### 方法 B: 使用新的 GitHub Actions 工作流
1. 访问: https://github.com/shi198472/ai-converter-system/actions
2. 点击 **"Deploy with New Cloudflare Token"**
3. 点击 **"Run workflow"**
4. 粘贴新 Token
5. 选择 **"是的，Token 正确"**
6. 点击 **"Run workflow"**

## 🚀 使用新 Token 部署

### 选项 1: 使用新工作流 (推荐)
使用 `deploy-with-new-token.yml` 工作流，支持输入新 Token。

### 选项 2: 更新现有工作流
获取新 Token 后，我可以更新工作流使用新 Token。

### 选项 3: 配置 GitHub Secrets
如果你希望自动化部署，可以配置 GitHub Secrets:
1. 在 GitHub 仓库设置中添加 `CLOUDFLARE_API_TOKEN`
2. 值为你的新 Token

## 🚨 常见问题解决

### 问题 1: Token 立即失效
**原因**: 可能复制不完整
**解决**: 重新生成，确保完整复制整个 Token

### 问题 2: 权限不足
**症状**: "You do not have permission" 或 "Forbidden"
**解决**: 确保有 `Account:Cloudflare Pages:Edit` 权限

### 问题 3: 找不到 "Edit Cloudflare Workers" 模板
**解决**: 
1. 点击 "Create Token"
2. 在模板列表中找到 "Edit Cloudflare Workers"
3. 如果找不到，选择 "Custom token" 然后手动添加权限

### 问题 4: Token 生成后无法使用
**解决**:
1. 等待几分钟让 Token 生效
2. 清除浏览器缓存
3. 重新登录 Cloudflare

## 📱 手机端操作指南

如果你在手机上：

1. 打开 Cloudflare 手机 App 或浏览器
2. 登录后点击菜单
3. 找到 "API Tokens"
4. 点击 "Create Token"
5. 选择 "Edit Cloudflare Workers" 模板

## 💡 Token 最佳实践

1. **为每个项目创建单独的 Token**
2. **设置合理的有效期** (建议 90天)
3. **不要分享 Token**，立即使用
4. **保存 Token 在安全的地方**
5. **定期轮换 Token** (每3个月)

## 🆘 紧急解决方案

如果还是无法获取有效 Token：

### 方案 A: 使用手动上传
```bash
./build-and-prepare.sh
# 然后按照脚本指导手动上传
```

### 方案 B: 使用 Wrangler CLI
```bash
npm install -g wrangler
wrangler login
wrangler pages deploy frontend/dist --project-name=ai-converter-system
```

### 方案 C: 联系 Cloudflare 支持
如果所有方法都失败: https://support.cloudflare.com/

## 📞 需要实时帮助？

如果你在获取 Token 时遇到问题：
1. **截图当前页面**
2. **描述具体错误**
3. **告诉我你卡在哪一步**

我会指导你完成。

---

**现在去获取新的有效 Token 吧！** 这是解决部署问题的关键。 🚀