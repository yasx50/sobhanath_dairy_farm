import bcrypt from "bcryptjs"

// Generate 6 digit OTP
export const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString()
}

// Hash OTP
export const hashOTP = async (otp) => {
  return await bcrypt.hash(otp, 10)
}

// Verify OTP
export const verifyOTP = async (enteredOtp, hashedOtp) => {
  return await bcrypt.compare(enteredOtp, hashedOtp)
}
