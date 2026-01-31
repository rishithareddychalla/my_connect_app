const bcrypt = require('bcrypt');
const { ApiError } = require('../../middlewares/error.middleware');
const User = require('../users/user.model');
const RefreshToken = require('./refresh_token.model');
const { generateAccessToken, generateRefreshToken, verifyToken } = require('../../utils/jwt');
const { verifyOtp, saveOtp, generateOtp, sendOtp } = require('../../utils/otp');

const requestOtp = async (phone) => {
    const otp = generateOtp();
    await saveOtp(phone, otp);
    await sendOtp(phone, otp);
    return { message: 'OTP sent successfully' };
};

const signup = async (body) => {
    const { phone, otp, fullName, password, businessName, category, email, website } = body;

    // 1. Verify OTP
    // Note: This consumes the OTP
    await verifyOtp(phone, otp);

    // 2. Check if user exists
    if (await User.findOne({ where: { phoneNumber: phone } })) {
        throw new ApiError(400, 'Phone number already registered');
    }

    // 3. Hash Password
    const passwordHash = await bcrypt.hash(password, 12);

    // 4. Create User
    const user = await User.create({
        phoneNumber: phone,
        passwordHash,
        fullName,
        businessName,
        category,
        email,
        website,
    });

    // 5. Generate Tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // 6. Save Refresh Token
    await RefreshToken.create({
        token: refreshToken,
        user_id: user.id,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
    });

    return { user, accessToken, refreshToken };
};

const login = async (body) => {
    const { phone, password } = body;

    const user = await User.findOne({ where: { phoneNumber: phone } });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
        throw new ApiError(401, 'Incorrect phone or password');
    }

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    await RefreshToken.create({
        token: refreshToken,
        user_id: user.id,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    });

    return { user, accessToken, refreshToken };
};

const refreshAuth = async (token) => {
    try {
        const decoded = verifyToken(token, true);
        const refreshTokenDoc = await RefreshToken.findOne({
            where: { token, isRevoked: false },
        });

        if (!refreshTokenDoc) {
            throw new Error();
        }

        const user = await User.findByPk(decoded.sub);
        if (!user) {
            throw new Error();
        }

        const newAccessToken = generateAccessToken(user.id);
        return { accessToken: newAccessToken };
    } catch (error) {
        throw new ApiError(401, 'Invalid refresh token');
    }
};

module.exports = {
    requestOtp,
    signup,
    login,
    refreshAuth,
    verifyOtp // Exporting just in case, though signup uses it internally
};
