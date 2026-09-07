import mongoose from "mongoose";
import dotenv from "dotenv";

dotenv.config();

const connection = {
  isConnected: false,
};

async function dbConnect() {
  if (connection.isConnected) {
    return;
  }

  try {
    const db = await mongoose.connect(process.env.MONGODB_URI);
    connection.isConnected = db.connection.readyState === 1;
  } catch (e) {
    console.error("Couldn't connect db", e);
    throw e;
  }
}

async function dbDisconnect() {
  if (!connection.isConnected) {
    return;
  }

  try {
    await mongoose.disconnect();
    connection.isConnected = false;
    console.log("MongoDB disconnected");
  } catch (e) {
    console.error("Couldn't disconnect db", e);
    throw e;
  }
}

export { dbDisconnect };
export default dbConnect;