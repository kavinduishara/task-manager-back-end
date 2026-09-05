import mongoose from "mongoose";
import dotenv from "dotenv";


dotenv.config()

const connection={}

async function dbConnect() {
    if(connection.isConnected){
        return;
    }
    try{
        const db=await mongoose.connect(process.env.MONGODB_URI)
        connection.isConnected=db.connection.readyState;

    }catch(e){
        console.error("couln't connect db",e)

    }
    
}

export default dbConnect;