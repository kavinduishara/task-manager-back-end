import Task from "../models/Task.js";

export const updateTaskInDb = async (taskId, updates) => {
  const task = await Task.findById(taskId);

  if (!task) {
    return null;
  }

  Object.assign(task, updates);

  await task.save();

  return Task.findById(task._id)
    .populate("creator", "name email")
    .populate("assignee", "name email");
};