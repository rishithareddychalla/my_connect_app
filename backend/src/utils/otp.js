const { redisClient } = require('../config/redis');
const { logger } = require('./logger');

// MOCK OTP for Phase 1
const generateOtp = () => {
    return '123456';
};

const sendOtp = async (phone, otp) => {
    logger.info(`[MOCK SMS] Sending OTP ${otp} to ${phone}`);
    // In production, integrate SMS gateway here
    return true;
};

const saveOtp = async (phone, otp) => {
    // Save OTP in Redis with 5 minute expiry (300 seconds)
    await redisClient.set(`otp:${phone}`, otp, {
        EX: 300
    });
};

const verifyOtp = async (phone, otpInput) => {
    // Phase 1: Accept ANY OTP if mock mode or check redis
    // But strict design said: Verifies OTP against Redis.
    // User said: "any otp acceptable".
    // So we will just return true for any OTP input, or check if it matches the mock.

    // Implementation: Check if an OTP was requested (exists in Redis) but ignore the value match check for now?
    // Or just accept anything.
    // Let's implement logic: Must match what's in Redis OR match '123456'.

    const savedOtp = await redisClient.get(`otp:${phone}`);

    if (!savedOtp && otpInput !== '123456') {
        throw new Error('OTP expired or not requested');
    }

    // Allow magic code or correct code
    if (otpInput === '123456' || otpInput === savedOtp) {
        await redisClient.del(`otp:${phone}`); // Consume OTP
        return true;
    }

    throw new Error('Invalid OTP');
};

module.exports = {
    generateOtp,
    sendOtp,
    saveOtp,
    verifyOtp
};
