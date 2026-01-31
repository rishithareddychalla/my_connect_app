const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/db');
const User = require('../users/user.model');

const RefreshToken = sequelize.define('RefreshToken', {
    token: {
        type: DataTypes.TEXT,
        allowNull: false,
        unique: true,
    },
    expiresAt: {
        type: DataTypes.DATE, // TIMESTAMPTZ
        allowNull: false,
        field: 'expires_at',
    },
    isRevoked: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        field: 'is_revoked',
    },
}, {
    tableName: 'refresh_tokens',
    timestamps: false,
    underscored: true,
});

// Association
RefreshToken.belongsTo(User, { foreignKey: 'user_id' });
User.hasMany(RefreshToken, { foreignKey: 'user_id' });

module.exports = RefreshToken;
