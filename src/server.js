import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import taskRoute from "./routes/taskRoute.js";


dotenv.config();

const app=express()

app.use(express.json());
app.use(cookieParser());

app.use("/api/tasks", taskRoute)


const PORT=process.env.PORT || 3001

const server =app.listen(PORT,()=>{
    console.log(`Server is running on port ${PORT}`)
})