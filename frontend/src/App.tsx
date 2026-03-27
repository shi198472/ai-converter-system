import React, { useState } from 'react';
import TaskInput from './components/TaskInput';
import TaskResult from './components/TaskResult';
import TaskHistory from './components/TaskHistory';
import { decomposeTask, saveTask } from './services/api';

export interface TaskStep {
  text: string;
  completed: boolean;
}

export interface TaskResultData {
  originalTask: string;
  steps: string[];
  stepCount: number;
}

const App: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<TaskResultData | null>(null);
  const [steps, setSteps] = useState<TaskStep[]>([]);
  const [refreshHistory, setRefreshHistory] = useState(0);

  const handleSubmit = async (task: string) => {
    setLoading(true);
    try {
      const data = await decomposeTask(task);
      setResult(data);
      setSteps(data.steps.map(step => ({ text: step, completed: false })));
    } catch (error) {
      console.error('Error:', error);
      alert('任务分解失败，请稍后重试');
    } finally {
      setLoading(false);
    }
  };

  const toggleStep = (index: number) => {
    const newSteps = [...steps];
    newSteps[index].completed = !newSteps[index].completed;
    setSteps(newSteps);
  };

  const handleSave = async () => {
    if (!result) return;
    
    try {
      await saveTask({
        originalTask: result.originalTask,
        steps: steps.map(s => s.text),
        completedSteps: steps.map(s => s.completed)
      });
      alert('任务已保存！');
      setRefreshHistory(prev => prev + 1);
    } catch (error) {
      console.error('Error saving:', error);
      alert('保存失败，请稍后重试');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        {/* Header */}
        <header className="text-center mb-10">
          <h1 className="text-4xl font-bold text-gray-800 mb-3">
            🤖 AI Converter System
          </h1>
          <p className="text-gray-600 text-lg">
            将复杂的任务转换为简单可执行的步骤
          </p>
        </header>

        {/* Main Content */}
        <main>
          <TaskInput onSubmit={handleSubmit} loading={loading} />
          
          {result && (
            <TaskResult
              result={result}
              steps={steps}
              onToggleStep={toggleStep}
              onSave={handleSave}
            />
          )}

          <TaskHistory key={refreshHistory} />
        </main>

        {/* Footer */}
        <footer className="text-center mt-12 text-gray-500 text-sm">
          <p>AI Converter System &copy; 2024</p>
        </footer>
      </div>
    </div>
  );
};

export default App;
