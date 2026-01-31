require('dotenv').config();
const app = require('./app');
const { logger } = require('./utils/logger');
const { sequelize } = require('./config/db');
const { redisClient } = require('./config/redis');

const PORT = process.env.PORT || 5000;

let server;

const startServer = async () => {
    try {
        // Connect to Database
        await sequelize.authenticate();
        logger.info('Connected to PostgreSQL');

        // Sync Database (Dev only - use migrations in prod)
        await sequelize.sync();

        // Connect to Redis
        await redisClient.connect();
        logger.info('Connected to Redis');

        server = app.listen(PORT, () => {
            logger.info(`Server listening on port ${PORT}`);
        });
    } catch (error) {
        logger.error('Failed to start server:', error);
        process.exit(1);
    }
};

startServer();

// Handle exit
const exitHandler = () => {
    if (server) {
        server.close(() => {
            logger.info('Server closed');
            process.exit(1);
        });
    } else {
        process.exit(1);
    }
};

const unexpectedErrorHandler = (error) => {
    logger.error(error);
    exitHandler();
};

process.on('uncaughtException', unexpectedErrorHandler);
process.on('unhandledRejection', unexpectedErrorHandler);

process.on('SIGTERM', () => {
    logger.info('SIGTERM received');
    if (server) {
        server.close();
    }
});
