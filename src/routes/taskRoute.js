import express from "express";

import {
  getAllTasks,
  getTaskById,
  addTasks,
  updateTask,
  deleteTask,
  updateTaskStatus,
  addSubtask,
  updateSubtask,
  removeSubtask,
} from "../controllers/taskController.js";

const router = express.Router();

router.get("/", getAllTasks);

router.get("/:id", getTaskById);

router.post("/", addTasks);

router.patch("/status/:id", updateTaskStatus);

router.post("/:id/subtasks", addSubtask);

router.patch("/:id/subtasks/:subtaskId", updateSubtask);

router.delete("/:id/subtasks/:subtaskId", removeSubtask);

router.patch("/:id", updateTask);

router.delete("/:id", deleteTask);

export default router;