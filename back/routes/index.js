const express = require('express');
const {reward} = require("../controller/index")
const router = express.Router();


// http://localhost:3001/reward
router.post('reward',reward);

module.exports = router;