const redis = require('redis');
const { logger } = require('../utils/logger');
require('dotenv').config();

const redisClient = redis.createClient({
    url: process.env.REDIS_URL
});

redisClient.on('error', (err) => logger.error('Redis Client Error', err));
redisClient.on('connect', () => logger.info('Redis Client Connected'));

module.exports = { redisClient };
