module.exports = {
  /**
   * Application configuration section
   * http://pm2.keymetrics.io/docs/usage/application-declaration/
   */
  apps : [
    // First application
    {
      name      : "API",
      script    : "./bin/api.js",
      env: {
        "APIPORT": 3030,
        "PORT": 8000,
        "NODE_ENV": "production",
        "SOCKETPORT": 4000,
        "SOCKETHOST": "ws.alphastack.com",
        "REDIS_ADDRESS": "redis://as-subscriptions.kqba54.ng.0001.use1.cache.amazonaws.com:6379"
      }
    },
    // Second application
    {
      name      : "WEB",
      script    : "./bin/server.js",
      env: {
        "APIPORT": 3030,
        "PORT": 8000,
        "NODE_ENV": "production",
        "SOCKETPORT": 4000,
        "SOCKETHOST": "ws.alphastack.com",
      }
    }
  ],
};
