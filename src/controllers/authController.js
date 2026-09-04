import bcrypt from "bcrypt";
import User from "../models/User.js";

const registerUser = async (req, res) => {
  const { name,email, password } = req.body;

  try {
    if (!name || !email || !password) {
      return res.status(400).json({
        error: "Username and password are required",
      });
    }

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({
        error: "User already exists",
      });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
    });

    // const token = generateToken(user._id, res);
    const token ="jkjnnwervnweivn"

    res.status(201).json({
      id: user._id,
      username: user.username,
      token,
    });
  } catch (error) {
    console.error("Error registering user:", error);

    res.status(500).json({
      error: "Internal server error",
    });
  }
};

const loginUser = async (req, res) => {
  // implement next
};

const logoutUser = (req, res) => {
  // implement next
};

export { registerUser, loginUser, logoutUser };