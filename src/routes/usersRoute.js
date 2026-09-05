import express from "express";
import { getAllUsers,getMyDetails } from "../controllers/userController.js";

const router = express.Router();

router.get("/", getAllUsers);

router.get("/me", getMyDetails);

export default router;