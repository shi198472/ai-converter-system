import { Router } from 'express';
import { v4 as uuidv4 } from 'uuid';
import OpenAI from 'openai';

const router = Router();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || '',
});

interface Task {
  id: string;
  originalTask: string;
  steps: Step[];
  createdAt: string;
  updatedAt: string;
}

interface Step {
  id: string;
  description: string;
  completed: boolean;
}

const tasks: Map<string, Task> = new Map();

router.post('/convert', async (req, res) => {
  try {
    const { task } = req.body;
    
    if (!task || typeof task !== 'string') {
      return res.status(400).json({ error: 'Task description is required' });
    }

    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: `你是一个任务分解专家。请将用户输入的复杂任务分解成5-10个简单、可执行的步骤。
每个步骤应该：
1. 具体且可操作
2. 按逻辑顺序排列
3. 使用简洁的语言描述
4. 确保步骤之间相互独立

请以JSON格式返回，格式如下：
{
  "steps": ["步骤1", "步骤2", "步骤3", ...]
}`
        },
        {
          role: 'user',
          content: `请将以下任务分解成简单步骤：${task}`
        }
      ],
      temperature: 0.7,
    });

    const responseContent = completion.choices[0]?.message?.content || '';
    let steps: string[] = [];
    
    try {
      const parsed = JSON.parse(responseContent);
      steps = parsed.steps || [];
    } catch {
      steps = responseContent
        .split('\n')
        .filter(line => line.trim())
        .map(line => line.replace(/^\d+\.\s*/, '').trim())
        .filter(line => line.length > 0);
    }

    const taskId = uuidv4();
    const newTask: Task = {
      id: taskId,
      originalTask: task,
      steps: steps.map((step, index) => ({
        id: uuidv4(),
        description: step,
        completed: false,
      })),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    tasks.set(taskId, newTask);

    res.json(newTask);
  } catch (error) {
    console.error('Error converting task:', error);
    res.status(500).json({ error: 'Failed to convert task' });
  }
});

router.get('/', (req, res) => {
  const taskList = Array.from(tasks.values()).sort(
    (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  );
  res.json(taskList);
});

router.get('/:id', (req, res) => {
  const task = tasks.get(req.params.id);
  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }
  res.json(task);
});

router.patch('/:id/steps/:stepId', (req, res) => {
  const task = tasks.get(req.params.id);
  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }

  const step = task.steps.find(s => s.id === req.params.stepId);
  if (!step) {
    return res.status(404).json({ error: 'Step not found' });
  }

  const { completed } = req.body;
  if (typeof completed === 'boolean') {
    step.completed = completed;
    task.updatedAt = new Date().toISOString();
  }

  res.json(task);
});

router.delete('/:id', (req, res) => {
  const deleted = tasks.delete(req.params.id);
  if (!deleted) {
    return res.status(404).json({ error: 'Task not found' });
  }
  res.json({ message: 'Task deleted successfully' });
});

export default router;