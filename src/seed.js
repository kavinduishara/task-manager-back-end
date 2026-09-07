import dbConnect,{dbDisconnect} from "./config/dbConnect.js";
import bcrypt from "bcrypt";
import User from "./models/User.js";


const users = [
  {
    name: "Admin",
    email: "admin@email.com",
    password: "k123",
    role: "ADMIN",
  },
];

async function seed() {
  try {
    await dbConnect();

    for (const userData of users) {
      const existingUser = await User.findOne({
        email: userData.email,
      });

      if (existingUser) {
        console.log(`Skipping ${userData.email}`);
        continue;
      }

      const hashedPassword = await bcrypt.hash(userData.password, 10);

      await User.create({
        name: userData.name,
        email: userData.email,
        password: hashedPassword,
        role: userData.role,
      });

      console.log(`Created ${userData.email}`);
    }

    console.log("Seeding completed");
  } catch (error) {
    console.error("Seeding failed:", error);
  } finally {
    await dbDisconnect();
  }
}

seed();