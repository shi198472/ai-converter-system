import { Clock, ChevronRight } from 'lucide-react';
import { Task } from '../types';

interface TaskHistoryProps {
  tasks: Task[];
  onSelect: (task: Task) => void;
  currentTaskId?: string;
}

export default function TaskHistory({ tasks, onSelect, currentTaskId }: TaskHistoryProps) {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('zh-CN', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <div className="flex items-center gap-2 mb-4">
        <Clock className="w-5 h-5 text-gray-500" />
        <h3 className="text-lg font-semibold text-gray-800">历史记录</h3>
      </div>

      {tasks.length === 0 ? (
        <p className="text-gray-500 text-sm text-center py-4">
          暂无历史任务
        </p>
      ) : (
        <div className="space-y-2 max-h-96 overflow-y-auto">
          {tasks.map((task) => {
            const completedSteps = task.steps.filter(s => s.completed).length;
            const isActive = task.id === currentTaskId;

            return (
              <button
                key={task.id}
                onClick={() => onSelect(task)}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  isActive
                    ? 'bg-blue-50 border border-blue-200'
                    : 'hover:bg-gray-50 border border-transparent'
                }`}
              >
                <p className="text-sm font-medium text-gray-800 line-clamp-2 mb-1">
                  {task.originalTask}
                </p>
                <div className="flex items-center justify-between text-xs text-gray-500">
                  <span>
                    {completedSteps}/{task.steps.length} 完成
                  </span>
                  <span>{formatDate(task.createdAt)}</span>
                </div>
                <ChevronRight className="w-4 h-4 text-gray-400 absolute right-3 top-1/2 -translate-y-1/2 opacity-0 group-hover:opacity-100" />
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}