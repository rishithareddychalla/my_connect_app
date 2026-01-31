const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/db');

const User = sequelize.define('User', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    phoneNumber: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        field: 'phone_number',
    },
    passwordHash: {
        type: DataTypes.STRING,
        allowNull: false,
        field: 'password_hash',
    },
    fullName: {
        type: DataTypes.STRING, // VARCHAR(100)
        allowNull: false,
        field: 'full_name',
    },
    businessName: {
        type: DataTypes.STRING,
        field: 'business_name',
    },
    category: {
        type: DataTypes.STRING,
    },
    profilePicUrl: {
        type: DataTypes.TEXT,
        field: 'profile_pic_url',
    },
    email: {
        type: DataTypes.STRING,
        unique: true,
        validate: { isEmail: true },
    },
    website: {
        type: DataTypes.STRING,
    },
}, {
    tableName: 'users',
    timestamps: true,
    underscored: true,
});

module.exports = User;
