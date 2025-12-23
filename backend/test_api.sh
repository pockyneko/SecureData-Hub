# SecureData Hub 后端接口测试脚本

# 1. 注册用户
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "test1234", "email": "testuser@example.com"}'

# 2. 登录获取JWT
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "test1234"}'
# 登录成功后会返回 { "token": "..." }

# 3. 获取私有数据（需替换<JWT_TOKEN>）
curl -X GET http://localhost:3000/api/data/private \
  -H "Authorization: Bearer <JWT_TOKEN>"

# 4. 插入测试私有数据（可在MySQL中执行）
# INSERT INTO PrivateData (user_id, content) VALUES (1, 'Hello SecureData Hub!');
