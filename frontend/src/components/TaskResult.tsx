import React from 'react';
import { TaskResultData, TaskStep } from '../App';

interface TaskResultProps {
  result: TaskResultData;
  steps: TaskStep[];
  onToggleStep: (index: number) => void;
  onSave: () => void;
}

const TaskResult: React.FC<TaskResultProps> = ({ result, steps, onToggleStep, onSave }) => {
  const completedCount = steps.filter(s => s.completed).length;
  const progress = steps.length > 0 ? (completedCount / steps.length) * 100 : 0;

  return (
    <div className="bg-white rounded-xl shadow-lg p-6 mb-8">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">
        任务分解结果
      </h2>
      
      {/* Original Task */}
      <div className="bg-blue-50 rounded-lg p-4 mb-6">
        <p className="text-sm text-blue-600 font-medium mb-1">原始任务</p>
        <p className="text-gray-800">{result.originalTask}</p>
      </div>

      {/* Progress */}
      <div className="mb-6">
        <div className="flex justify-between text-sm text-gray-600 mb-2">
          <span>完成进度</span>
          <span>{completedCount} / {steps.length}</span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div
            className="bg-green-500 h-2 rounded-full transition-all duration-300"
            style={{ width: `${progress}%` }}
          ></div>
        </div>
      </div>

      {/* Steps */}
      <div className="space-y-3">
        {steps.map((step, index) => (
          <div
            key={index}
            onClick={() => onToggleStep(index)}
            className={`flex items-start p-4 rounded-lg border-2 cursor-pointer transition-all ${
              step.completed
                ? 'bg-green-50 border-green-300'
                : 'bg-gray-50 border-gray-200 hover:border-blue-300'
            }`}
          >
            <div className={`flex-shrink-0 w-6 h-6 rounded-full border-2 flex items-center justify-center mr-3 mt-0.5 ${
              step.completed
                ? 'bg-green-500 border-green-500'
                : 'border-gray-300'
            }`}>
              {step.completed && (
                <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
              )}
            </div>
            <div className="flex-1">
              <p className={`font-medium ${step.completed ? 'text-gray-500 line-through' : 'text-gray-800'}`}>
                步骤 {index + 1}
              </p>
              <p className={`mt-1 ${step.completed ? 'text-gray-400 line-through' : 'text-gray-600'}`}>
                {step.text}
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Save Button */}
      <button
        onClick={onSave}
        className="mt-6 w-full py-3 px-6 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 active:scale-95 transition-all"
      >
        保存任务
      </button>
    </div>
  );
};

export default TaskResult;
