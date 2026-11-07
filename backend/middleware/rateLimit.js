const buckets = new Map();

const createRateLimit = ({ windowMs, max }) => (req, res, next) => {
    const now = Date.now();
    const key = req.ip || req.socket.remoteAddress || "unknown";
    let bucket = buckets.get(key);

    if (!bucket || bucket.resetAt <= now) {
        bucket = { count: 0, resetAt: now + windowMs };
        buckets.set(key, bucket);
    }

    bucket.count += 1;
    if (bucket.count > max) {
        return res.status(429).json({
            success: false,
            message: "Too many requests. Please try again later.",
        });
    }

    if (buckets.size > 10000) {
        for (const [ip, entry] of buckets) {
            if (entry.resetAt <= now) buckets.delete(ip);
        }
    }

    return next();
};

exports.authRateLimit = createRateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10,
});
