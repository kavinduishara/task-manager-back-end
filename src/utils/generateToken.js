import jwt from "jsonwebtoken";

const generateToken = (userId,res) => {
    const payload = {
        id: userId,
    };
    // Return the token (this would typically use a library like jsonwebtoken)

    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: "1h" });
    res.cookie("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict",
        maxAge: 3600000, // 1 hour in milliseconds
    });
    return token;
};

export default generateToken;