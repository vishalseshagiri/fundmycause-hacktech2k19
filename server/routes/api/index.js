const express = require('express');
const router = express.Router();

router.use('/uber', require('./uber'));

module.exports = router;
