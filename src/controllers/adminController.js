import { seedData } from "../../seed.js";
import Task from "../models/Task.js";


export const getAllTasks=async (req, res)=>{

    res.json({ message: "All tasks fetched successfully",
        data: seedData
    });
}