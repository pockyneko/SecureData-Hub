// 后端入口文件
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());


// 路由占位
app.get('/', (req, res) => {
  res.send('SecureData Hub Backend Running');
});

// 引入auth路由
const authRouter = require('./routes/auth');
app.use('/api/auth', authRouter);


// 引入data路由
const dataRouter = require('./routes/data');
app.use('/api/data', dataRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
