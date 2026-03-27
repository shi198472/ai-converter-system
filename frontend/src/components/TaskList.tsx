import { useState } from 'react';
import { Check, CheckCircle2, Circle, Trash2, ChevronDown, ChevronUp } from 'lucide-react';
import { updateStep, deleteTask } from '../api';
import { Task } from '../types';

interface TaskListProps {
  task: Task;
  onUpdate: (task: Task) => void;
}

export default function TaskList({ task, onUpdate }: TaskListProps) {
  const [expanded, setExpanded] = useState(true);

  const handleToggleStep = async (stepId: string, completed: boolean) => {
    try {
      const updatedTask = await updateStep(task.id, stepId, !completed);
      onUpdate(updatedTask);
    } catch (error) {
      console.error('Error updating step:', error);
    }
  };

  const handleDelete = async () => {
    if (!confirm('确定要删除这个任务吗？')) return;
    
    try {
      await deleteTask(task.id);
      onUpdate({ ...task, id: '' } as Task);
    } catch (error) {
      console.error('Error deleting task:', error);
    }
  };

  const completedSteps = task.steps.filter(s => s.completed).length;
  const progress = task.steps.length > 0 
    ? Math.round((completedSteps / task.steps.length) * 100) 
    : 0;

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <div className="p-6 border-b border-gray-100">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-gray-800 mb-2">
              {task.originalTask}
            </h3>
            <div className="flex items-center gap-4 text-sm text-gray-500">
              <span>
                {completedSteps} / {task.steps.length} 完成
              </span>
              <span>•</span>
              <span>{progress}%</span>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setExpanded(!expanded)}
              className="p-2 text-gray-400 hover:text-gray-600 transition-colors"
            >
              {expanded ? (
                <ChevronUp className="w-5 h-5" />
              ) : (
                <ChevronDown className="w-5 h-5" />
              )}
            </button>
            <button
              onClick={handleDelete}
              className="p-2 text-red-400 hover:text-red-600 transition-colors"
            >
              <Trash2 className="w-5 h-5" />
            </button>
          </div>
        </div>

        <div className="mt-4">
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-blue-500 h-2 rounded-full transition-all duration-300"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>
      </div>

      {expanded && (
        <div className="divide-y divide-gray-100">
          {task.steps.map((step, index) => (
            <div
              key={step.id}
              className={`p-4 flex items-start gap-3 hover:bg-gray-50 transition-colors ${
                step.completed ? 'bg-gray-50' : ''
              }`}
            >
              <button
                onClick={() => handleToggleStep(step.id, step.completed)}
                className={`mt-0.5 flex-shrink-0 ${
                  step.completed ? 'text-green-500' : 'text-gray-400 hover:text-gray-600'
                }`}
              >
                {step.completed ? (
                  <CheckCircle2 className="w-5 h-5" />
                ) : (
                  <Circle className="w-5 h-5" />
                )}
              </button>
              <div className="flex-1">
                <span
                  className={`text-sm ${
                    step.completed
                      ? 'text-gray-400 line-through'
                      : 'text-gray-700'
                  }`}
                >
                  <span className="font-medium text-gray-500 mr-2">
                    {index + 1}.
                  </span>
                  {step.description}
                </span>
              </div>
              {step.completed && (
                <Check className="w-4 h-4 text-green-500 flex-shrink-0" />
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}