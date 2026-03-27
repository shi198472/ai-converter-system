import React, { useState } from 'react';

interface TaskInputProps {
  onSubmit: (task: string) => void;
  loading: boolean;
}

const TaskInput: React.FC<TaskInputProps> = ({ onSubmit, loading }) => {
  const [task, setTask] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (task.trim()) {
      onSubmit(task.trim());
    }
  };

  const examples = [
    '我想学习Python编程',
    '如何准备一场演讲',
    '计划一次日本旅行',
    '写一篇技术博客文章'
  ];

  return (
    <div className="bg-white rounded-xl shadow-lg p-6 mb-8">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">
        输入你的任务
      </h2>
      
      <form onSubmit={handleSubmit}>
        <textarea
          value={task}
          onChange={(e) => setTask(e.target.value)}
          placeholder="描述你想要完成的复杂任务，AI将帮你分解为简单步骤..."
          className="w-full p-4 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none h-32 text-gray-700"
          disabled={loading}
        />
        
        <button
          type="submit"
          disabled={loading || !task.trim()}
          className={`mt-4 w-full py-3 px-6 rounded-lg font-semibold text-white transition-all ${
            loading || !task.trim()
              ? 'bg-gray-400 cursor-not-allowed'
              : 'bg-blue-600 hover:bg-blue-700 active:scale-95'
          }`}
        >
          {loading ? (
            <span className="flex items-center justify-center">
              <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              正在分解任务...
            </span>
          ) : (
            '开始分解任务'
          )}
        </button>
      </form>

      {/* Examples */}
      <div className="mt-6">
        <p className="text-sm text-gray-500 mb-2">示例任务：</p>
        <div className="flex flex-wrap gap-2">
          {examples.map((example, index) => (
            <button
              key={index}
              onClick={() => setTask(example)}
              className="text-sm px-3 py-1 bg-gray-100 text-gray-600 rounded-full hover:bg-gray-200 transition-colors"
            >
              {example}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default TaskInput;
