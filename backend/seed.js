const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

mongoose.connect("mongodb://localhost:27017/attendance_app");

const User = require("./models/User");

async function createUser() {

    const hashedPassword = await bcrypt.hash("Hod@123", 10);

    await User.create({
        name: "Anu Varghese",
        email: "anu@mescas.org",
        password: hashedPassword,
        role: "HOD",
        department: "Computer Science"
    });

    console.log("HOD Created");
    process.exit();
}


createUser();