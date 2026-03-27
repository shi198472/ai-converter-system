import { Request, Response } from 'express';
import OpenAI from 'openai';

// 内存存储（生产环境应使用数据库）
interface Task {
  id: string;
  originalTask: string;
  steps: string[];
  completedSteps: boolean[];
  createdAt: Date;
}

const taskHistory: Task[] = [];

export class TaskController {
  private openai: OpenAI;

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  // 分解任务
  decomposeTask = async (req: Request, res: Response) => {
    try {
      const { task } = req.body;

      if (!task || typeof task !== 'string') {
        return res.status(400).json({ error: 'Task description is required' });
      }

      const completion = await this.openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: `你是一个任务分解专家。你的任务是将复杂的任务分解成简单、可执行的步骤。
            
请遵循以下规则：
1. 将任务分解为 3-8 个具体步骤
2. 每个步骤应该清晰、可执行
3. 步骤之间应该有逻辑顺序
4. 使用简洁的语言描述每个步骤

请直接返回步骤列表，每行一个步骤，以数字开头。'
            `
          },
          {
            role: 'user',
            content: `请将以下任务分解成简单可执行的步骤：\n\n${task}`
          }
        ],
        temperature: 0.7,
      });

      const response = completion.choices[0]?.message?.content || '';
      
      // 解析步骤
      const steps = response
        .split('\n')
        .map(line => line.trim())
        .filter(line => /^\d+[.、)\s]/.test(line))
        .map(line => line.replace(/^\d+[.、)\s]+/, '').trim())
        .filter(step => step.length > 0);

      // 如果没有解析到步骤，使用整段文本
      const finalSteps = steps.length > 0 ? steps : [response];

      res.json({
        originalTask: task,
        steps: finalSteps,
        stepCount: finalSteps.length
      });
    } catch (error) {
      console.error('Error decomposing task:', error);
      res.status(500).json({ error: 'Failed to decompose task' });
    }
  };

  // 获取历史记录
  getHistory = (req: Request, res: Response) => {
    res.json({
      tasks: taskHistory.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
    });
  };

  // 保存任务
  saveTask = (req: Request, res: Response) => {
    try {
      const { originalTask, steps, completedSteps } = req.body;

      const task: Task = {
        id: Date.now().toString(),
        originalTask,
        steps,
        completedSteps: completedSteps || new Array(steps.length).fill(false),
        createdAt: new Date()
      };

      taskHistory.push(task);

      res.json({ success: true, task });
    } catch (error) {
      console.error('Error saving task:', error);
      res.status(500).json({ error: 'Failed to save task' });
    }
  };
}
