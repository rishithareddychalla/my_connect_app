const express = require('express');
const authController = require('./auth.controller');
// const validate = require('../../middlewares/validate.middleware'); // Optional: validation middleware using Joi
// const authValidation = require('./auth.validation');

const router = express.Router();

router.post('/request-otp', authController.requestOtp);
router.post('/signup', authController.signup);
router.post('/verify-otp', authController.verifyOtp);
router.post('/login', authController.login);
router.post('/refresh', authController.refreshTokens);
// router.post('/logout', authController.logout);

module.exports = router;
