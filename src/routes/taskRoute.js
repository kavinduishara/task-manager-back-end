import express from "express";
import { addTasks, getAllTasks } from "../controllers/taskController.js";

const router = express.Router();

router.get("/", getAllTasks);

router.post("/", addTasks);

export default router;