# 🔑 获取正确的 Cloudflare API Token

## 问题原因
你遇到的 "Authentication error" 是因为当前的 Token 无效。可能是：
1. Token 已过期
2. Token 权限不足
3. Token 格式错误
4. 需要的是 API Token 而不是 User Token

## 🎯 获取正确 Token 的步骤

### 步骤 1: 登录 Cloudflare Dashboard
1. 打开: https://dash.cloudflare.com/
2. 使用你的账户登录

### 步骤 2: 进入 API Tokens 页面
1. 点击右上角你的头像
2. 选择 "My Profile" (我的资料)
3. 点击左侧的 "API Tokens" (API 令牌)

![步骤2](https://docs.cloudflare.com/static/8e9c5d5d5e5e5e5e5e5e5e5e5e5e5e5/api-tokens-nav.png)

### 步骤 3: 创建新的 Token
1. 点击蓝色的 **"Create Token"** (创建令牌) 按钮

![步骤3](https://docs.cloudflare.com/static/8e9c5d5d5e5e5e5e5e5e5e5e5e5e5/create-token-button.png)

### 步骤 4: 选择模板
**重要**: 选择 **"Edit Cloudflare Workers"** 模板

![选择模板](https://docs.cloudflare.com/static/8e9c5d5d5e5e5e5e5e5e5e5e5e5e5/template-select.png)

### 步骤 5: 配置权限
确保有以下权限：

#### Account Resources (账户资源)
- `Account:Cloudflare Pages:Edit` ✅ **必须**
- `Account:Workers Scripts:Edit` ✅ 推荐

#### Zone Resources (区域资源)
- 选择 "All zones" (所有区域) 或你的特定域名

![权限配置](https://docs.cloudflare.com/static/8e9c5d5d5e5e5e5e5e5e5e5e5e5e5/permissions-config.png)

### 步骤 6: 设置 Token 名称和有效期
1. **Token name** (令牌名称): `ai-converter-system-deploy`
2. **Client IP Address Filtering** (客户端 IP 地址过滤): 留空
3. **TTL** (有效期): 建议选择 "Custom" → 90天

### 步骤 7: 创建并复制 Token
1. 点击 **"Continue to summary"** (继续到摘要)
2. 检查配置，点击 **"Create Token"** (创建令牌)
3. **立即复制生成的 Token** (只显示一次！)

![复制Token](https://docs.cloudflare.com/static/8e9c5d5d5e5e5e5e5e5e5e5e5e5e5/copy-token.png)

## 🔧 验证 Token 是否有效

### 方法 A: 使用验证脚本
```bash
# 在项目目录运行
./direct-deploy.sh
```

输入新 Token，脚本会自动验证。

### 方法 B: 手动验证
```bash
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer YOUR_NEW_TOKEN" \
  -H "Content-Type: application/json"
```

如果返回 `"success": true`，说明 Token 有效。

## 🚀 使用新 Token 重新部署

### 选项 1: 使用 GitHub Actions (推荐)
1. 回到: https://github.com/shi198472/ai-converter-system/actions
2. 点击 "Deploy to Cloudflare Pages"
3. 点击 "Run workflow"
4. 使用新 Token

### 选项 2: 使用直接部署脚本
```bash
# 在项目目录运行
./direct-deploy.sh
```

## 🚨 常见 Token 问题

### 问题 1: Token 立即失效
**原因**: 可能复制不完整
**解决**: 重新生成，确保完整复制

### 问题 2: 权限不足
**症状**: "You do not have permission"
**解决**: 确保有 `Account:Cloudflare Pages:Edit` 权限

### 问题 3: IP 限制
**症状**: "Cannot use token from this IP"
**解决**: 在创建 Token 时不要设置 IP 限制

### 问题 4: Token 类型错误
**需要的是**: API Token (以 `CF_` 或 `CFP_` 开头)
**不是**: User Token (以 `cfut_` 开头)

## 📱 快速检查清单

- [ ] 使用了 "Edit Cloudflare Workers" 模板
- [ ] 有 `Account:Cloudflare Pages:Edit` 权限
- [ ] Token 有效期足够长 (90天)
- [ ] 完整复制了 Token (没有截断)
- [ ] 没有设置 IP 限制
- [ ] 验证 Token 返回 `"success": true`

## 💡 最佳实践

1. **为每个项目创建单独的 Token**
2. **设置合理的有效期** (90天)
3. **定期轮换 Token** (每3个月)
4. **不要分享 Token**，立即使用
5. **保存 Token 在安全的地方**

## 🆘 紧急解决方案

如果还是不行，可以使用：

### 方案 A: 使用 Global API Key
1. 在 API Tokens 页面
2. 找到 "Global API Key" 部分
3. 点击 "View" 查看
4. 使用这个 Key 作为 Token

### 方案 B: 联系 Cloudflare 支持
如果所有方法都失败，联系: https://support.cloudflare.com/

## 📞 需要帮助？

如果你在获取 Token 时遇到问题：
1. 截图当前页面
2. 描述具体错误
3. 告诉我你卡在哪一步

我会指导你完成。

---

**现在去获取正确的 Token 吧！** 完成后我们就可以成功部署了。 🚀