const validatePhone = (phone) => {
    // Basic E.164 regex or just check length
    // Accepts +1234567890
    const re = /^\+[1-9]\d{1,14}$/;
    return re.test(phone);
};

const validateEmail = (email) => {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
};

module.exports = {
    validatePhone,
    validateEmail
};
