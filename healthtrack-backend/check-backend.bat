@REM 后端功能快速检测脚本 (Windows)
@echo off
setlocal enabledelayedexpansion

echo.
echo 🚀 HealthTrack 后端功能检测工具
echo ==================================

REM 检查 Node.js
echo.
echo 1️⃣ 检查环境...
where node >nul 2>nul
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo ✓ Node.js: !NODE_VERSION!
) else (
    echo ✗ Node.js 未安装
    pause
    exit /b 1
)

REM 检查 npm
where npm >nul 2>nul
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo ✓ npm: !NPM_VERSION!
) else (
    echo ✗ npm 未安装
    pause
    exit /b 1
)

REM 进入后端目录
cd /d "%~dp0"

REM 安装依赖
echo.
echo 2️⃣ 安装/更新依赖...
call npm install
if !errorlevel! equ 0 (
    echo ✓ 依赖安装完成
) else (
    echo ✗ 依赖安装失败
    pause
    exit /b 1
)

REM 检查测试文件
echo.
echo 3️⃣ 检查测试文件...
if exist "tests\personalizedHealth.test.js" (
    echo ✓ 单元测试文件存在
) else (
    echo ✗ 单元测试文件缺失
)

if exist "tests\personalized-health-api.http" (
    echo ✓ API 测试文件存在
) else (
    echo ✗ API 测试文件缺失
)

REM 检查配置
echo.
echo 4️⃣ 检查配置文件...
if exist "jest.config.js" (
    echo ✓ Jest 配置存在
) else (
    echo ✗ Jest 配置缺失
)

REM 显示可用命令
echo.
echo 5️⃣ 可用的测试命令
echo ==================================
echo.
echo 快速选项：
echo   npm run dev              - 启动开发服务器
echo   npm test                 - 运行所有单元测试
echo   npm test -- --watch      - 监视模式运行测试
echo   npm test -- --coverage   - 显示代码覆盖率
echo.
echo 数据库选项：
echo   npm run init-db          - 初始化数据库
echo   npm run seed             - 导入种子数据
echo.
echo VS Code 测试：
echo   1. 打开: tests\personalized-health-api.http
echo   2. 安装 REST Client 插件
echo   3. 点击 'Send Request' 测试 API
echo.

REM 健康检查
echo 6️⃣ 快速健康检查
echo ==================================
if exist ".env" (
    echo ✓ .env 文件存在
    findstr /M "DB_HOST" .env >nul && echo   ✓ 数据库配置已设置
    findstr /M "JWT_SECRET" .env >nul && echo   ✓ JWT 密钥已设置
) else (
    echo ⚠ .env 文件缺失，请创建
)

echo.
echo ✓ 检测完成！系统就绪
echo ==================================
echo.
echo 建议步骤：
echo   1. 运行 npm run dev 启动服务
echo   2. 使用 REST Client 或 Jest 测试
echo   3. 查看 BACKEND_TESTING_GUIDE.md 了解详情
echo.
pause
