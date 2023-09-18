const express = require('express');
require('express-async-errors');
const sequelize = require('./database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('./user.model');
const log4js = require("log4js");
const logger = log4js.getLogger("auth");
const app = express();

log4js.addLayout("json", function (config) {
  return function (logEvent) {
    return JSON.stringify(logEvent) + config.separator;
  };
});

log4js.configure({
  appenders: {
    out: { type: "stdout", layout: { type: "json", separator: "," } },
  },
  categories: {
    default: { appenders: ["out"], level: "info" },
  },
});

app.use(express.json());

const port = +process.env.PORT ?? 3001;

app.listen(port, () => {
  logger.info(`Users Service at ${port}`);
});

app.get('/liveness', async (req, res) => {
  logger.info('/liveness called')
  return res.status(200).json({status:"success"});
});

app.get('/readiness', async (req, res) => {
  logger.info('/readiness called')
  return res.status(200).json({status:"success"});
});

app.post('/signup', async (req, res) => {
  let { name, email, password } = req.body;
  password = await bcrypt.hash(password, 12);

  await User.create({ name, email, password });
  const payload = {
    email,
    name,
  };
  jwt.sign(payload, process.env.JWT_SECRET, (err, token) => {
    if (err) {
      logger.error(err);
    } else {
      logger.info("function:signup, name:%s,email:%s, token:%s", name, email, token);
    }
    res.status(200).json({ token, name, email });
  });
});

app.post('/signin', async (req, res) => {
  let { email, password } = req.body;

  const user = await User.findOne({ where: { email } });
  if (!user) {
    logger.warn("User not found")
    return res.status(404).json({ error: 'User not found' });
  }
  if (await bcrypt.compare(password, user.password)) {
    const payload = {
      email: user.email,
      name: user.name,
    };
    jwt.sign(payload, process.env.JWT_SECRET, (err, token) => {
      if (err) {
        logger.error(err);
      } else {
        logger.info("function:signin, name:%s,email:%s, token:%s", user.name, email, token);
      }
      res.status(200).json({ token, name: user.name, email });
    });
  } else {
    logger.warn("Unauthorized")
    res.status(401).json({ error: 'Unauthorized' });
  }
});

sequelize.sync();
