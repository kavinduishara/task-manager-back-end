import Task from "../models/Task.js";
import User from "../models/User.js";

// GET /api/tasks
export const getAllTasks = async (req, res) => {
  try {
    const tasks = await Task.find()
      .populate("creator", "name email")
      .populate("assignee", "name email")
      .sort({ createdAt: -1 });

    res.status(200).json({
      message: "All tasks fetched successfully",
      data: tasks,
    });
  } catch (error) {
    console.error("Error fetching tasks:", error);

    res.status(500).json({
      message: "Failed to fetch tasks",
    });
  }
};

// GET /api/tasks/:id
export const getTaskById = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate("creator", "name email")
      .populate("assignee", "name email");

    if (!task) {
      return res.status(404).json({
        message: "Task not found",
      });
    }

    res.status(200).json({
      message: "Task fetched successfully",
      data: task,
    });
  } catch (error) {
    console.error("Error fetching task:", error);

    res.status(500).json({
      message: "Failed to fetch task",
    });
  }
};

// POST /api/tasks
export const addTasks = async (req, res) => {
  try {
    const {
      title,
      description,
      status,
      assignee,
      dueDate,
    } = req.body;

    const requestedUser = req.user;

    if (!title || !description || !status) {
      return res.status(400).json({
        message: "Title, description and status are required",
      });
    }

    // USER can only assign the task to themselves
    if (
      requestedUser.role !== "ADMIN" &&
      assignee &&
      assignee !== requestedUser.id
    ) {
      return res.status(403).json({
        message: "Users can't assign tasks to others",
      });
    }

    // Check assignee exists
    if (assignee) {
      const user = await User.findById(assignee);

      if (!user) {
        return res.status(404).json({
          message: "Assignee not found",
        });
      }
    }

    const task = await Task.create({
      title,
      description,
      status,
      assignee,
      dueDate,
      creator: requestedUser.id,
    });

    const populatedTask = await Task.findById(task._id)
      .populate("creator", "name email")
      .populate("assignee", "name email");

    res.status(201).json({
      message: "Task added successfully",
      task: populatedTask,
    });
  } catch (error) {
    console.error("Error creating task:", error);

    res.status(500).json({
      message: "Failed to add task",
    });
  }
};

// PATCH /api/tasks/:id
export const updateTask = async (req, res) => {
  try {
    const {
      title,
      description,
      status,
      assignee,
      dueDate,
    } = req.body;

    const requestedUser = req.user;

    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({
        message: "Task not found",
      });
    }

    // USER can only edit their own tasks
    if (
      requestedUser.role !== "ADMIN" &&
      task.creator.toString() !== requestedUser.id
    ) {
      return res.status(403).json({
        message: "You can only edit tasks you created",
      });
    }

    // USER can only assign task to themselves
    if (
      requestedUser.role !== "ADMIN" &&
      assignee !== undefined &&
      assignee !== requestedUser.id
    ) {
      return res.status(403).json({
        message: "Users can't assign tasks to others",
      });
    }

    // Check assignee exists
    if (assignee !== undefined && assignee !== null) {
      const user = await User.findById(assignee);

      if (!user) {
        return res.status(404).json({
          message: "Assignee not found",
        });
      }
    }

    if (title !== undefined) task.title = title;
    if (description !== undefined) task.description = description;
    if (status !== undefined) task.status = status;
    if (assignee !== undefined) task.assignee = assignee;
    if (dueDate !== undefined) task.dueDate = dueDate;

    await task.save();

    const updatedTask = await Task.findById(task._id)
      .populate("creator", "name email")
      .populate("assignee", "name email");

    res.status(200).json({
      message: "Task updated successfully",
      task: updatedTask,
    });
  } catch (error) {
    console.error("Error updating task:", error);

    res.status(500).json({
      message: "Failed to update task",
    });
  }
};

// DELETE /api/tasks/:id
export const deleteTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({
        message: "Task not found",
      });
    }

    const requestedUser = req.user;

    // USER can only delete their own tasks
    if (
      requestedUser.role !== "ADMIN" &&
      task.creator.toString() !== requestedUser.id
    ) {
      return res.status(403).json({
        message: "You can only delete tasks you created",
      });
    }

    await Task.findByIdAndDelete(req.params.id);

    res.status(200).json({
      message: "Task deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting task:", error);

    res.status(500).json({
      message: "Failed to delete task",
    });
  }
};