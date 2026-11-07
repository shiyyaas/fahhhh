const mongoose = require("mongoose");
const User = require("../models/User");
const Student = require("../models/Student");
const Teacher = require("../models/Teacher");
const Department = require("../models/Department");
const Batch = require("../models/Batch");
const Subject = require("../models/Subject");
const Leave = require("../models/Leave");
const { getDepartmentScope } = require("../utils/departmentScope");

const respondForbidden = (res) =>
    res.status(403).json({ success: false, message: "Forbidden" });

const getOwnRecipientIds = async (req) => {
    const user = await User.findById(req.user.userId).select("email role");
    if (!user || user.role !== req.user.role) return null;

    const ids = [String(user._id)];
    const Profile = user.role === "STUDENT"
        ? Student
        : user.role === "TEACHER"
            ? Teacher
            : null;
    if (Profile) {
        const profile = await Profile.findOne({ email: user.email }).select("_id");
        if (profile) ids.push(String(profile._id));
    }
    return ids;
};

const belongsToHodDepartment = async (req, resource, resourceType) => {
    const user = await User.findById(req.user.userId).select("department role");
    if (!user || user.role !== "HOD" || !user.department) return false;

    if (resourceType === "student" || resourceType === "batch") {
        return resource.department === user.department;
    }

    const department = await Department.findOne({
        departmentName: user.department
    }).select("_id");
    if (!department) return false;

    const departmentId = String(department._id);
    if (resourceType === "teacher") {
        return (resource.departments || []).some(
            (id) => String(id) === departmentId
        );
    }
    if (resourceType === "subject") {
        return (resource.departments || []).some(
            (id) => String(id) === departmentId
        );
    }
    if (resourceType === "department") {
        return resource.departmentName === user.department;
    }
    return false;
};

const requireProfileOwnership = (Model, paramName) =>
    async (req, res, next) => {
        if (req.user.role === "HOD") {
            if (!mongoose.Types.ObjectId.isValid(req.params[paramName])) {
                return res.status(400).json({
                    success: false,
                    message: `Invalid ${Model.modelName.toLowerCase()} ID`,
                });
            }
            try {
                const resource = await Model.findById(req.params[paramName])
                    .select(Model === Student ? "department" : "departments");
                if (!resource) {
                    return res.status(404).json({
                        success: false,
                        message: `${Model.modelName} not found`,
                    });
                }
                if (!await belongsToHodDepartment(
                    req,
                    resource,
                    Model === Student ? "student" : "teacher"
                )) {
                    return respondForbidden(res);
                }
                return next();
            } catch (error) {
                return res.status(500).json({
                    success: false,
                    message: "Unable to verify resource ownership",
                });
            }
        }

        if (req.user.role !== Model.modelName.toUpperCase()) {
            return respondForbidden(res);
        }

        const profileId = req.params[paramName];
        if (!mongoose.Types.ObjectId.isValid(profileId)) {
            return res.status(400).json({
                success: false,
                message: `Invalid ${Model.modelName.toLowerCase()} ID`,
            });
        }

        try {
            const user = await User.findById(req.user.userId).select("email role");
            if (!user || user.role !== req.user.role) {
                return respondForbidden(res);
            }

            const profile = await Model.findOne({
                _id: profileId,
                email: user.email,
            }).select("_id");

            if (!profile) {
                return respondForbidden(res);
            }

            return next();
        } catch (error) {
            return res.status(500).json({
                success: false,
                message: "Unable to verify resource ownership",
            });
        }
    };

exports.requireStudentOrHod = (paramName) =>
    requireProfileOwnership(Student, paramName);

exports.requireTeacherOrHod = (paramName) =>
    requireProfileOwnership(Teacher, paramName);

exports.requireOwnUser = (paramName) =>
    (req, res, next) => {
        if (req.user.role === "HOD" ||
            req.user.userId === req.params[paramName]) {
            return next();
        }
        return respondForbidden(res);
    };

exports.requireOwnNotificationRecipient = (paramName) =>
    async (req, res, next) => {
        if (!mongoose.Types.ObjectId.isValid(req.params[paramName])) {
            return res.status(400).json({
                success: false,
                message: "Invalid user ID",
            });
        }
        try {
            const ids = await getOwnRecipientIds(req);
            if (!ids || !ids.includes(String(req.params[paramName]))) {
                return respondForbidden(res);
            }
            req.notificationRecipientIds = ids;
            return next();
        } catch (error) {
            return res.status(500).json({
                success: false,
                message: "Unable to verify resource ownership",
            });
        }
    };

exports.requireOwnNotification = async (req, res, next) => {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid notification ID",
        });
    }
    try {
        const ids = await getOwnRecipientIds(req);
        if (!ids) return respondForbidden(res);
        req.notificationRecipientIds = ids;
        return next();
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Unable to verify resource ownership",
        });
    }
};

exports.requireHodDepartmentResource = (Model, paramName, resourceType) =>
    async (req, res, next) => {
        if (req.user.role !== "HOD") return respondForbidden(res);
        if (!mongoose.Types.ObjectId.isValid(req.params[paramName])) {
            return res.status(400).json({
                success: false,
                message: `Invalid ${resourceType} ID`,
            });
        }
        try {
            const projection = resourceType === "batch" || resourceType === "student"
                ? "department"
                : resourceType === "department"
                    ? "departmentName"
                    : "departments";
            const resource = await Model.findById(req.params[paramName])
                .select(projection);
            if (!resource) {
                return res.status(404).json({
                    success: false,
                    message: `${resourceType} not found`,
                });
            }
            if (!await belongsToHodDepartment(req, resource, resourceType)) {
                return respondForbidden(res);
            }
            return next();
        } catch (error) {
            return res.status(500).json({
                success: false,
                message: "Unable to verify resource ownership",
            });
        }
    };

exports.requireHodLeaveDepartment = async (req, res, next) => {
    if (req.user.role !== "HOD") return respondForbidden(res);
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid leave ID",
        });
    }
    try {
        const leave = await Leave.findById(req.params.id)
            .select("applicantId applicantType");
        if (!leave) {
            return res.status(404).json({
                success: false,
                message: "Leave not found",
            });
        }
        const Profile = leave.applicantType === "STUDENT"
            ? Student
            : leave.applicantType === "TEACHER"
                ? Teacher
                : null;
        if (!Profile) return respondForbidden(res);
        const projection = leave.applicantType === "STUDENT"
            ? "department"
            : "departments";
        const profile = await Profile.findById(leave.applicantId).select(projection);
        if (!profile || !await belongsToHodDepartment(
            req,
            profile,
            leave.applicantType.toLowerCase()
        )) {
            return respondForbidden(res);
        }
        return next();
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Unable to verify leave ownership",
        });
    }
};

exports.requireOwnStudentBatchOrHod = (paramName) =>
    async (req, res, next) => {
        if (req.user.role === "HOD") {
            return exports.requireHodDepartmentResource(Batch, paramName, "batch")(
                req,
                res,
                next
            );
        }
        if (req.user.role !== "STUDENT") {
            return respondForbidden(res);
        }
        if (!mongoose.Types.ObjectId.isValid(req.params[paramName])) {
            return res.status(400).json({
                success: false,
                message: "Invalid batch ID",
            });
        }

        try {
            const scope = await getDepartmentScope(req);
            if (!scope || !scope.batchIds ||
                !scope.batchIds.some((id) => String(id) === String(req.params[paramName]))) {
                return respondForbidden(res);
            }
            return next();
        } catch (error) {
            return res.status(500).json({
                success: false,
                message: "Unable to verify resource ownership",
            });
        }
    };
