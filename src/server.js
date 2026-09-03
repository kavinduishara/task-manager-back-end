import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";

import applicationRoutes from "./routes/applicationRoutes.js";

dotenv.config();
connectDB()

const app=express()

app.use(express.json());
app.use(cookieParser());

app.use("/api/applications",applicationRoutes)


const PORT=process.env.PORT || 3000

const server =app.listen(PORT,()=>{
    console.log(`Server is running on port ${PORT}`)
})