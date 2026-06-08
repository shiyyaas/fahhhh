const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.login = async (req, res) => {
    try {

        const { email, password } = req.body;

        console.log("LOGIN REQUEST RECEIVED");
        console.log("EMAIL:", email);

        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: "Email and Password required"
            });
        }

        const user = await User.findOne({
            email: email.toLowerCase().trim()
        });

        console.log("USER FOUND:", user);

        if (!user) {
            return res.status(401).json({
                success: false,
                message: "User not found"
            });
        }

        const isMatch = await bcrypt.compare(
            password,
            user.password
        );

        console.log("PASSWORD ENTERED:", password);
        console.log("HASH FROM DB:", user.password);
        console.log("PASSWORD MATCH:", isMatch);

        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: "Invalid password"
            });
        }

        const token = jwt.sign(
            {
                userId: user._id,
                role: user.role
            },
            process.env.JWT_SECRET,
            {
                expiresIn: "7d"
            }
        );

        return res.status(200).json({
            success: true,
            message: "Login successful",
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                department: user.department
            }
        });

    } catch (error) {

        console.error("LOGIN ERROR:", error);

        return res.status(500).json({
            success: false,
            message: error.message
        });

    }
};