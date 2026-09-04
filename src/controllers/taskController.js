import { seedData } from "../../seed.js";
import Task from "../models/Task.js";


export const getAllTasks=async (req, res)=>{

    res.json({ message: "All tasks fetched successfully",
        data: seedData
    });
}

export const addTasks = async (req, res) => {
  try {
    const { title, description, status, creator, assignee, dueDate } = req.body;

    const task = new Task({
      title,
      description,
      status,
      creator,
      assignee,
      dueDate,
    });

    await task.save();

    res.status(201).json({
      message: "Task added successfully",
      task,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to add task",
      error: error.message,
    });
  }
};