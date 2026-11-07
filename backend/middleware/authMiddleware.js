const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");
const User = require("../models/User");

// Verify JWT Token

exports.verifyToken = async (req, res, next) => {

    try {

        const authorization = req.headers.authorization;
        const [scheme, token, ...extra] = authorization
            ? authorization.split(" ")
            : [];

        if (scheme !== "Bearer" || !token || extra.length > 0) {

            return res.status(401).json({
                success: false,
                message: "Access denied"
            });

        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET
        );
        if (!decoded.userId ||
            !decoded.role ||
            !mongoose.Types.ObjectId.isValid(decoded.userId)) {
            return res.status(401).json({
                success: false,
                message: "Invalid token"
            });
        }

        const user = await User.findById(decoded.userId).select("role isActive");
        if (!user || user.isActive === false || user.role !== decoded.role) {
            return res.status(401).json({
                success: false,
                message: "Invalid token"
            });
        }

        req.user = decoded;

        return next();

    } catch (error) {

        return res.status(error.name === "JsonWebTokenError" ||
            error.name === "TokenExpiredError" ||
            error.name === "NotBeforeError" ||
            error.name === "CastError" ? 401 : 500).json({
            success: false,
            message: error.name === "JsonWebTokenError" ||
                error.name === "TokenExpiredError" ||
                error.name === "NotBeforeError" ||
                error.name === "CastError"
                ? "Invalid token"
                : "Unable to verify token"
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