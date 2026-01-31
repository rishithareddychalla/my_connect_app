const authService = require('./auth.service');
const { ApiError } = require('../../middlewares/error.middleware');

const requestOtp = async (req, res, next) => {
    try {
        const result = await authService.requestOtp(req.body.phone);
        res.send(result);
    } catch (error) {
        next(error);
    }
};

const signup = async (req, res, next) => {
    try {
        const result = await authService.signup(req.body);
        res.status(200).send(result);
    } catch (error) {
        next(error);
    }
};

const verifyOtp = async (req, res, next) => {
    try {
        const result = await authService.verifyOtp(req.body);
        res.status(201).send(result); // 201 Created
    } catch (error) {
        next(error);
    }
};

const login = async (req, res, next) => {
    try {
        const result = await authService.login(req.body);
        res.send(result);
    } catch (error) {
        next(error);
    }
};

const refreshTokens = async (req, res, next) => {
    try {
        const result = await authService.refreshAuth(req.body.refreshToken);
        res.send(result);
    } catch (error) {
        next(error);
    }
};

module.exports = {
    requestOtp,
    signup,
    verifyOtp,
    login,
    refreshTokens,
};
