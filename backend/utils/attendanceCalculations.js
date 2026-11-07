const effectivePresent = (present, late, policy = process.env.LATE_AS || "present") => {
  if (policy === "partial") return present + late * 0.5;
  if (policy === "absent") return present;
  return present + late;
};

const attendancePercentage = (present, late, total, policy) =>
  total === 0 ? 0 : (effectivePresent(present, late, policy) / total) * 100;

const formatAttendancePercentage = (present, late, total, policy) =>
  attendancePercentage(present, late, total, policy).toFixed(2);

module.exports = {
  effectivePresent,
  attendancePercentage,
  formatAttendancePercentage
};
