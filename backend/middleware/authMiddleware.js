const jwt = require("jsonwebtoken");

// Verify JWT Token

exports.verifyToken = (req, res, next) => {

    try {

        const token =
            req.headers.authorization?.split(" ")[1];

        if (!token) {

            return res.status(401).json({
                success: false,
                message: "Access denied"
            });

        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET
        );

        req.user = decoded;

        next();

    } catch (error) {

        return res.status(401).json({
            success: false,
            message: "Invalid token"
        });

    }

};

// Role Authorization

exports.authorizeRoles =
    (...roles) => {

        return (
            req,
            res,
            next
        ) => {

            if (
                !roles.includes(
                    req.user.role
                )
            ) {

                return res.status(403).json({
                    success: false,
                    message: "Forbidden"
                });

            }

            next();

        };

    };