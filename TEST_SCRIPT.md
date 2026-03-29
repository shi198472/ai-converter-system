# AI Converter System 测试脚本

## 快速测试指南

### 1. 环境检查
```bash
# 检查Node.js版本
node --version

# 检查npm版本
npm --version

# 检查Git状态
git status
```

### 2. 依赖安装测试
```bash
# 后端依赖
cd backend
npm install
npm list --depth=0

# 前端依赖
cd ../frontend
npm install
npm list --depth=0
```

### 3. 构建测试
```bash
# 后端TypeScript编译
cd backend
npm run build

# 前端构建（可选）
cd ../frontend
npm run build
```

### 4. 运行测试
```bash
# 启动后端服务（需要OpenAI API Key）
cd backend
# 先创建.env文件
cp .env.example .env
# 编辑.env文件添加你的OpenAI API Key
# 然后启动服务
npm run dev

# 在另一个终端启动前端
cd frontend
npm start
```

### 5. API测试
```bash
# 使用curl测试API
curl -X POST http://localhost:3001/api/tasks/convert \
  -H "Content-Type: application/json" \
  -d '{"task": "学习如何做一顿美味的意大利面"}'

# 健康检查
curl http://localhost:3001/api/health

# 获取历史记录
curl http://localhost:3001/api/tasks
```

### 6. 浏览器测试
1. 打开浏览器访问: http://localhost:3000
2. 输入测试任务: "学习如何做一顿美味的意大利面"
3. 点击"分解任务"按钮
4. 查看AI分解的步骤
5. 勾选完成步骤
6. 点击"保存任务"按钮

## 测试用例

### 用例1: 学习任务
- **输入**: "学习Python编程"
- **预期**: 返回5-8个具体的学习步骤
- **验证**: 步骤应该清晰、可执行、有逻辑顺序

### 用例2: 项目任务
- **输入**: "开发一个简单的待办事项应用"
- **预期**: 返回开发流程的各个阶段
- **验证**: 应该包括需求分析、技术选型、开发、测试等步骤

### 用例3: 生活任务
- **输入**: "计划一次周末旅行"
- **预期**: 返回旅行准备的各个步骤
- **验证**: 应该包括目的地选择、交通、住宿、活动安排等

## 错误处理测试

### 测试1: 空任务
```bash
curl -X POST http://localhost:3001/api/tasks/convert \
  -H "Content-Type: application/json" \
  -d '{"task": ""}'
```
**预期**: 返回400错误，提示"Task description is required"

### 测试2: 无效JSON
```bash
curl -X POST http://localhost:3001/api/tasks/convert \
  -H "Content-Type: application/json" \
  -d 'invalid json'
```
**预期**: 返回400错误，JSON解析失败

### 测试3: 缺少OpenAI API Key
```bash
# 删除或注释.env中的OPENAI_API_KEY
curl -X POST http://localhost:3001/api/tasks/convert \
  -H "Content-Type: application/json" \
  -d '{"task": "测试任务"}'
```
**预期**: 返回500错误，提示"Failed to decompose task"

## 性能测试

### 响应时间测试
```bash
# 测试API响应时间
time curl -X POST http://localhost:3001/api/tasks/convert \
  -H "Content-Type: application/json" \
  -d '{"task": "测试性能"}'
```

### 并发测试
```bash
# 同时发送5个请求
for i in {1..5}; do
  curl -X POST http://localhost:3001/api/tasks/convert \
    -H "Content-Type: application/json" \
    -d "{\"task\": \"测试任务$i\"}" &
done
```

## 前端功能测试

### 1. 界面布局
- [ ] 页面加载正常
- [ ] 响应式设计适配不同屏幕
- [ ] 颜色和字体一致

### 2. 交互功能
- [ ] 输入框可以正常输入
- [ ] 提交按钮可以点击
- [ ] 步骤可以勾选/取消
- [ ] 保存按钮可以点击

### 3. 错误处理
- [ ] 网络错误时显示友好提示
- [ ] 输入为空时提示用户
- [ ] 加载状态显示正确

## 部署测试

### 生产构建
```bash
# 前端生产构建
cd frontend
npm run build

# 后端生产构建
cd ../backend
npm run build

# 启动生产服务
npm start
```

### 端口检查
```bash
# 检查端口占用
netstat -tulpn | grep :3000
netstat -tulpn | grep :3001

# 或者使用lsof
lsof -i :3000
lsof -i :3001
```

## 自动化测试建议

### 单元测试
```bash
# 安装测试框架
npm install --save-dev jest @types/jest ts-jest

# 运行测试
npm test
```

### E2E测试
```bash
# 使用Cypress或Playwright
npm install --save-dev cypress
```

## 测试报告

完成以上测试后，记录结果：

- [ ] 环境检查通过
- [ ] 依赖安装成功
- [ ] 构建成功
- [ ] API功能正常
- [ ] 前端界面正常
- [ ] 错误处理正常
- [ ] 性能可接受
- [ ] 部署成功

---

**测试完成时间**: 2024年3月29日  
**测试人员**: 运营小智  
**测试环境**: Node.js v18+, npm 9+  
**测试状态**: ✅ 通过基本功能测试