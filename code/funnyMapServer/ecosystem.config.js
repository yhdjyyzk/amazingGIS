module.exports = {
  apps: [
    {
      name: 'funnyMapServer',
      script: "./src/index.js",
      watch: true,
      instances: 4,
      error_file: './logs/error.log',
      out_file: './logs/out.log',
      log_file: './logs/log.log'
    },
  ]
};
