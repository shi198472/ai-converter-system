import axios from 'axios';

// 支持环境变量配置 API 地址
// 开发环境: http://localhost:3001
// 生产环境: 通过环境变量 VITE_API_URL 配置
const API_BASE_URL = import.meta.env.VITE_API_URL || '/api';

export interface DecomposeResponse {
  originalTask: string;
  steps: string[];
  stepCount: number;
}

export interface SaveTaskRequest {
  originalTask: string;
  steps: string[];
  completedSteps: boolean[];
}

export const decomposeTask = async (task: string): Promise<DecomposeResponse> => {
  const response = await axios.post(`${API_BASE_URL}/tasks/decompose`, { task });
  return response.data;
};

export const getHistory = async () => {
  const response = await axios.get(`${API_BASE_URL}/tasks/history`);
  return response.data;
};

export const saveTask = async (data: SaveTaskRequest) => {
  const response = await axios.post(`${API_BASE_URL}/tasks/save`, data);
  return response.data;
};
