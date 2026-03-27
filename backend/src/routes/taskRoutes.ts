import { Router } from 'express';
import { TaskController } from '../controllers/taskController';

const router = Router();
const taskController = new TaskController();

// 分解任务
router.post('/decompose', taskController.decomposeTask);

// 获取任务历史
router.get('/history', taskController.getHistory);

// 保存任务
router.post('/save', taskController.saveTask);

export default router;
