const jwt = require('jsonwebtoken');
require('dotenv').config();

const generateAccessToken = (userId) => {
    return jwt.sign({ sub: userId, type: 'access' }, process.env.JWT_SECRET, {
        expiresIn: '15m',
    });
};

const generateRefreshToken = (userId) => {
    return jwt.sign({ sub: userId, type: 'refresh' }, process.env.JWT_REFRESH_SECRET, {
        expiresIn: '7d',
    });
};

const verifyToken = (token, isRefresh = false) => {
    const secret = isRefresh ? process.env.JWT_REFRESH_SECRET : process.env.JWT_SECRET;
    try {
        return jwt.verify(token, secret);
    } catch (error) {
        throw new Error('Invalid token');
    }
};

module.exports = {
    generateAccessToken,
    generateRefreshToken,
    verifyToken,
};
