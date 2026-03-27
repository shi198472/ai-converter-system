# AI Converter System

🤖 一个AI任务转换系统，把复杂的事情转换成一系列简单的事情，便于简单执行。

## 项目介绍

AI Converter System 是一个基于 OpenAI API 的智能任务分解工具。它能够帮助用户将复杂的任务描述转换为清晰、可执行的简单步骤列表，让复杂的工作变得简单易懂。

## 技术栈

- **前端**: React + TypeScript + Tailwind CSS + Vite
- **后端**: Node.js + Express + TypeScript
- **AI集成**: OpenAI API (GPT-3.5-turbo)

## 核心功能

1. ✅ 用户输入复杂任务描述
2. 🤖 AI将复杂任务分解为多个简单步骤
3. 📋 显示步骤列表，支持勾选完成
4. 💾 保存历史记录

## 快速开始

### 环境要求

- Node.js >= 16
- npm 或 yarn
- OpenAI API Key

### 安装步骤

1. 克隆项目
```bash
git clone https://github.com/shi198472/ai-converter-system.git
cd ai-converter-system
```

2. 安装后端依赖
```bash
cd backend
npm install
```

3. 配置环境变量
```bash
cp .env.example .env
# 编辑 .env 文件，添加你的 OpenAI API Key
```

4. 安装前端依赖
```bash
cd ../frontend
npm install
```

### 运行项目

1. 启动后端服务
```bash
cd backend
npm run dev
```

2. 启动前端开发服务器
```bash
cd frontend
npm run dev
```

3. 打开浏览器访问 http://localhost:3000

## 项目结构

```
ai-converter-system/
├── backend/              # 后端代码
│   ├── src/
│   │   ├── index.ts     # 入口文件
│   │   └── routes/      # API路由
│   ├── package.json
│   └── tsconfig.json
├── frontend/            # 前端代码
│   ├── src/
│   │   ├── components/  # React组件
│   │   ├── api/         # API调用
│   │   ├── types/       # TypeScript类型
│   │   └── App.tsx      # 主应用
│   ├── package.json
│   └── vite.config.ts
└── README.md
```

## API 接口

### POST /api/tasks/convert
将复杂任务转换为简单步骤

**请求体:**
```json
{
  "task": "学习Python编程"
}
```

**响应:**
```json
{
  "id": "uuid",
  "originalTask": "学习Python编程",
  "steps": [
    { "id": "uuid", "description": "步骤1", "completed": false }
  ],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### GET /api/tasks
获取所有任务历史

### GET /api/tasks/:id
获取单个任务详情

### PATCH /api/tasks/:id/steps/:stepId
更新步骤完成状态

### DELETE /api/tasks/:id
删除任务

## 部署

### 生产环境构建

1. 构建前端
```bash
cd frontend
npm run build
```

2. 构建后端
```bash
cd backend
npm run build
```

3. 启动生产服务
```bash
cd backend
npm start
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License