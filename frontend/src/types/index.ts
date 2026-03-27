export interface Step {
  id: string;
  description: string;
  completed: boolean;
}

export interface Task {
  id: string;
  originalTask: string;
  steps: Step[];
  createdAt: string;
  updatedAt: string;
}