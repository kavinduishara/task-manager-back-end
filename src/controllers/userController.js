import Task from "../models/Task.js";
import User from "../models/User.js";


export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find();

    res.status(200).json({
      message: "All Users fetched successfully",
      data: users,
    });
  } catch (error) {
    console.error("Error fetching tasks:", error);

    res.status(500).json({
      message: "Failed to fetch tasks",
    });
  }
};

export const getMyDetails = async (req, res) => {
  try {
    const requestedUser = req.user;

    const user = await User.findById(requestedUser.id).lean();
    const tasks = await Task.find({ assignee: requestedUser.id });

    
    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    const { password, ...userWithoutPassword } = user;

    res.status(200).json({
      message: "User details fetched successfully",
      data: {
        user:userWithoutPassword,
        tasks:tasks
      },
    });
  } catch (error) {
    console.error("Error fetching user details:", error);

    res.status(500).json({
      message: "Failed to fetch user details",
    });
  }
};
