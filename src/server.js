import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import taskRoute from "./routes/taskRoute.js";
import authRoute from "./routes/authRoute.js";
import dbConnect from "./config/dbConnect.js";
import authMiddleware from "./middleware/authMiddleware.js";


dotenv.config();

dbConnect()

const app=express()

app.use(express.json());
app.use(cookieParser());

app.use("/api/auth",authRoute)

app.use(authMiddleware)
app.use("/api/tasks", taskRoute)



const PORT=process.env.PORT || 3001

const server =app.listen(PORT,()=>{
    console.log(`Server is running on port ${PORT}`)
})