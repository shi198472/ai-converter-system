# 🚀 一键部署到 Cloudflare Pages

## 最简单的方法：直接在 GitHub 页面上点击部署

### 步骤 1: 打开 GitHub Actions 页面
**点击这个链接**: https://github.com/shi198472/ai-converter-system/actions

### 步骤 2: 找到部署工作流
在左侧找到 **"Deploy to Cloudflare Pages"**，点击它。

### 步骤 3: 点击运行按钮
点击蓝色的 **"Run workflow"** 按钮。

### 步骤 4: 填写表单
你会看到一个表单，填写：

1. **cloudflare_api_token**:
   ```
   cfut_oAnzbjPIMcBXllDi6uPmsjcfat_LW9x9I8E21H2i36TuXP4BwwcRQ0VGxjDrroM2lpa3a526fff
   ```

2. **cloudflare_account_id** (已自动填写):
   ```
   907dc1ca42c6f0e75b5ea92bb02c8aa6
   ```

3. **project_name** (已自动填写):
   ```
   ai-converter-system
   ```

### 步骤 5: 点击运行
点击绿色的 **"Run workflow"** 按钮。

## ⏱️ 等待部署完成

部署过程需要 2-3 分钟，你会看到：

1. ✅ 代码检出
2. ✅ Node.js 环境设置
3. ✅ 依赖安装
4. ✅ 项目构建
5. ✅ 部署到 Cloudflare Pages

## 🌐 访问你的网站

部署完成后，访问：
```
https://ai-converter-system.pages.dev
```

## 📊 查看部署状态

### 在 GitHub 上查看：
1. 回到 Actions 页面: https://github.com/shi198472/ai-converter-system/actions
2. 点击运行中的工作流
3. 查看每个步骤的日志

### 在 Cloudflare 上查看：
1. 登录 Cloudflare Dashboard
2. 进入 Workers & Pages
3. 查看 ai-converter-system 项目

## 🚨 如果部署失败

### 常见问题 1: Token 无效
**症状**: "Authentication error"
**解决**: 
- 检查 Token 是否完整复制
- 确保 Token 未过期
- 重新生成 Token 并重试

### 常见问题 2: 构建失败
**症状**: "npm run build failed"
**解决**:
- 查看构建日志中的具体错误
- 检查 Node.js 版本兼容性

### 常见问题 3: 部署超时
**症状**: 部署过程卡住
**解决**:
- 等待几分钟后重试
- 检查网络连接

## 🔧 手动部署备选方案

如果一键部署不工作，可以使用命令行：

```bash
# 1. 克隆项目
git clone https://github.com/shi198472/ai-converter-system.git
cd ai-converter-system

# 2. 运行部署脚本
chmod +x simple-deploy.sh
./simple-deploy.sh
```

## 📞 获取帮助

如果遇到任何问题：
1. 截图错误信息
2. 提供工作流运行 ID
3. 描述具体问题

我会帮你解决。

---

**开始部署吧！点击这个链接开始：**
https://github.com/shi198472/ai-converter-system/actions/workflows/deploy-to-cloudflare-pages.yml

**预计时间**: 3-5分钟  
**难度**: ⭐☆☆☆☆ (点点按钮就行)