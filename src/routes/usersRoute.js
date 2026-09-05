import express from "express";
import { getAllUsers,getMyDetails, getMyTasks } from "../controllers/userController.js";

const router = express.Router();

router.get("/", getAllUsers);

router.get("/me", getMyDetails);
router.get("/myTasks", getMyTasks);


export default router;