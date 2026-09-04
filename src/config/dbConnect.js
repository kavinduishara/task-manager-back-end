import mongoose from "mongoose";
import dotenv from "dotenv";


dotenv.config()

const connection={}

async function dbConnect() {
    if(connection.isConnected){
        return;
    }
    const db=await mongoose.connect(process.env.MONGODB_URI)
    connection.isConnected=db.connection.readyState;
}

export default dbConnect;