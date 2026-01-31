const express = require('express');
const authRoute = require('./modules/auth/auth.routes');
// const userRoute = require('./modules/users/user.routes');
// const connectionRoute = require('./modules/connections/connection.routes');

const router = express.Router();

const defaultRoutes = [
    {
        path: '/auth',
        route: authRoute,
    },
    // {
    //   path: '/users',
    //   route: userRoute,
    // },
];

defaultRoutes.forEach((route) => {
    router.use(route.path, route.route);
});

module.exports = router;
