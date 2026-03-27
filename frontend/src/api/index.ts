import axios from 'axios';
import { Task } from '../types';

const API_BASE_URL = '/api';

export const convertTask = async (task: string): Promise<Task> => {
  const response = await axios.post(`${API_BASE_URL}/tasks/convert`, { task });
  return response.data;
};

export const getTasks = async (): Promise<Task[]> => {
  const response = await axios.get(`${API_BASE_URL}/tasks`);
  return response.data;
};

export const updateStep = async (
  taskId: string,
  stepId: string,
  completed: boolean
): Promise<Task> => {
  const response = await axios.patch(
    `${API_BASE_URL}/tasks/${taskId}/steps/${stepId}`,
    { completed }
  );
  return response.data;
};

export const deleteTask = async (taskId: string): Promise<void> => {
  await axios.delete(`${API_BASE_URL}/tasks/${taskId}`);
};