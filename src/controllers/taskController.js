export const getAllTasks=async (req, res)=>{
    res.json({ message: "Tasks retrieved successfully",});
}

export const addTasks=async (req, res)=>{
    res.status(201).json({ message: "Task added successfully",});
}