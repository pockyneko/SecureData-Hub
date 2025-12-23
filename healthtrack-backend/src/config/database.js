/**
 * MySQL 数据库连接池配置
 */

const mysql = require('mysql2/promise');
const config = require('./index');

// 创建连接池
const pool = mysql.createPool({
  host: config.database.host,
  port: config.database.port,
  user: config.database.user,
  password: config.database.password,
  database: config.database.database,
  connectionLimit: config.database.connectionLimit,
  waitForConnections: config.database.waitForConnections,
  queueLimit: config.database.queueLimit,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

// 测试数据库连接
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('✅ 数据库连接成功');
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ 数据库连接失败:', error.message);
    return false;
  }
}

// 执行查询的便捷方法
async function query(sql, params = []) {
  try {
    // 使用 pool.query 而不是 pool.execute
    // pool.query 会在客户端进行参数转义，对 LIMIT 等参数支持更好
    const [rows] = await pool.query(sql, params);
    return rows;
  } catch (error) {
    console.error('数据库查询错误:', error.message);
    throw error;
  }
}

// 事务执行
async function transaction(callback) {
  const connection = await pool.getConnection();
  await connection.beginTransaction();
  
  try {
    const result = await callback(connection);
    await connection.commit();
    return result;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

module.exports = {
  pool,
  query,
  transaction,
  testConnection
};
