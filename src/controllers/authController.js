import bcrypt from "bcrypt";
import User from "../models/User.js";
import generateToken from "../utils/generateToken.js";

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
      role:"User"
    });

    const token = generateToken(user._id, res,user.role);

    res.status(201).json({
      id: user._id,
      name:user.name, 
      email: user.email,
      role:user.role

    });
  } catch (error) {
    console.error("Error registering user:", error);

    res.status(500).json({
      error: "Internal server error",
    });
  }
};

const loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(401).json({
                error: "Invalid username or password"
            });
        }

        const passwordMatch = await bcrypt.compare(
            password,
            user.password
        );

        if (!passwordMatch) {
            return res.status(401).json({
                error: "Invalid username or password"
            });
        }
        const token = generateToken(user.id,res,user.role);

        res.status(200).json({
            message: "Login successful",
            user: {
                id: user.id,
                username: user.username
            },
        });

    } catch (error) {
        console.error("Error logging in user:", error);

        res.status(500).json({
            error: "Internal server error"
        });
    }
};

const logoutUser = (req, res) => {
    res.clearCookie("token", {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict",
    });
    res.status(200).json({ message: "Logout successful" });
}
export { registerUser, loginUser, logoutUser };