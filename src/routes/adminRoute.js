import express from "express";
import { getAllTasks } from "../controllers/adminController.js";

const router = express.Router();

router.get("/", getAllTasks);

export default router;