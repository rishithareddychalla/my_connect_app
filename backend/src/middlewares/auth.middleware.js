const { verifyToken } = require('../utils/jwt');
const { ApiError } = require('./error.middleware');

const auth = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new ApiError(401, 'Access token missing or invalid');
        }

        const token = authHeader.split(' ')[1];
        const decoded = verifyToken(token, false); // false = access token

        req.user = decoded; // { sub: userId, type: 'access' }
        next();
    } catch (error) {
        next(new ApiError(401, 'Please authenticate'));
    }
};

module.exports = auth;
