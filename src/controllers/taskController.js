import { seedData } from "../../seed.js";

export const getAllTasks=async (req, res)=>{

    res.json({ message: "All tasks fetched successfully",
        data: seedData
    });
}

export const addTasks=async (req, res)=>{
    res.status(201).json({ message: "Task added successfully",});
}