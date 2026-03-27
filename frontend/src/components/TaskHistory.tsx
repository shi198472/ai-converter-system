import React, { useState, useEffect } from 'react';
import { getHistory } from '../services/api';

interface Task {
  id: string;
  originalTask: string;
  steps: string[];
  completedSteps: boolean[];
  createdAt: string;
}

const TaskHistory: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    try {
      const data = await getHistory();
      setTasks(data.tasks || []);
    } catch (error) {
      console.error('Error fetching history:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-lg p-6">
        <p className="text-gray-500 text-center">加载历史记录...</p>
      </div>
    );
  }

  if (tasks.length === 0) {
    return (
      <div className="bg-white rounded-xl shadow-lg p-6">
        <h2 className="text-xl font-semibold text-gray-800 mb-4">历史记录</h2>
        <p className="text-gray-500 text-center py-4">暂无历史记录</p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow-lg p-6">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">历史记录</h2>
      
      <div className="space-y-4">
        {tasks.map((task) => {
          const completedCount = task.completedSteps.filter(Boolean).length;
          const progress = (completedCount / task.steps.length) * 100;
          
          return (
            <div key={task.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
              <div className="flex justify-between items-start mb-2">
                <h3 className="font-medium text-gray-800 line-clamp-1">{task.originalTask}</h3>
                <span className="text-xs text-gray-500">
                  {new Date(task.createdAt).toLocaleDateString()}
                </span>
              </div>
              
              <div className="flex items-center text-sm text-gray-600">
                <span className="mr-4">{task.steps.length} 个步骤</span>
                <span>{completedCount} 个已完成</span>
              </div>
              
              <div className="mt-2 w-full bg-gray-200 rounded-full h-1.5">
                <div
                  className="bg-blue-500 h-1.5 rounded-full"
                  style={{ width: `${progress}%` }}
                ></div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default TaskHistory;
