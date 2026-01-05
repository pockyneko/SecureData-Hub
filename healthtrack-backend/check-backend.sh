#!/bin/bash
# 后端功能快速检测脚本

echo "🚀 HealthTrack 后端功能检测工具"
echo "================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查 Node.js
echo -e "\n${BLUE}1️⃣ 检查环境${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js 未安装"
    exit 1
fi

# 检查 npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm: $NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm 未安装"
    exit 1
fi

# 检查 MySQL
if command -v mysql &> /dev/null; then
    echo -e "${GREEN}✓${NC} MySQL 已安装"
else
    echo -e "${YELLOW}⚠${NC} MySQL 客户端未安装"
fi

# 安装依赖
echo -e "\n${BLUE}2️⃣ 安装/更新依赖${NC}"
cd healthtrack-backend
if npm install; then
    echo -e "${GREEN}✓${NC} 依赖安装完成"
else
    echo -e "${RED}✗${NC} 依赖安装失败"
    exit 1
fi

# 检查测试文件
echo -e "\n${BLUE}3️⃣ 检查测试文件${NC}"
if [ -f "tests/personalizedHealth.test.js" ]; then
    echo -e "${GREEN}✓${NC} 单元测试文件存在"
else
    echo -e "${RED}✗${NC} 单元测试文件缺失"
fi

if [ -f "tests/personalized-health-api.http" ]; then
    echo -e "${GREEN}✓${NC} API 测试文件存在"
else
    echo -e "${RED}✗${NC} API 测试文件缺失"
fi

# 检查配置文件
echo -e "\n${BLUE}4️⃣ 检查配置文件${NC}"
if [ -f "jest.config.js" ]; then
    echo -e "${GREEN}✓${NC} Jest 配置存在"
else
    echo -e "${RED}✗${NC} Jest 配置缺失"
fi

if [ -f ".vscode/extensions.json" ]; then
    echo -e "${GREEN}✓${NC} VS Code 扩展配置存在"
else
    echo -e "${YELLOW}⚠${NC} VS Code 扩展配置缺失"
fi

# 显示可用的测试命令
echo -e "\n${BLUE}5️⃣ 可用的测试命令${NC}"
echo -e "${YELLOW}已准备就绪！使用以下命令开始测试：${NC}"
echo ""
echo -e "${GREEN}快速选项：${NC}"
echo "  1. npm run dev              # 启动开发服务器"
echo "  2. npm test                 # 运行所有单元测试"
echo "  3. npm test -- --watch      # 监视模式运行测试"
echo "  4. npm test -- --coverage   # 显示代码覆盖率"
echo ""
echo -e "${GREEN}数据库选项：${NC}"
echo "  5. npm run init-db          # 初始化数据库"
echo "  6. npm run seed             # 导入种子数据"
echo ""
echo -e "${GREEN}VS Code 测试：${NC}"
echo "  • 打开: tests/personalized-health-api.http"
echo "  • 点击 'Send Request' 按钮测试 API"
echo "  • 需要先安装 REST Client 插件"
echo ""

# 建议
echo -e "\n${BLUE}💡 建议步骤：${NC}"
echo "1. 在 VS Code 中安装推荐的扩展"
echo "   Ctrl+Shift+P > Shell Command: Install 'code' command in PATH"
echo "   然后运行: code --install-extension humao.rest-client"
echo ""
echo "2. 启动后端服务"
echo "   npm run dev"
echo ""
echo "3. 选择测试方案："
echo "   • API 测试: 打开 tests/personalized-health-api.http"
echo "   • 单元测试: npm test"
echo "   • 调试: F5 启动调试器"
echo ""
echo "4. 查看详细指南"
echo "   📖 BACKEND_TESTING_GUIDE.md"
echo ""

# 快速健康检查
echo -e "\n${BLUE}⚙️ 快速健康检查${NC}"

# 检查 .env 文件
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} .env 文件存在"
    # 检查关键变量
    if grep -q "DB_HOST" .env; then
        echo -e "${GREEN}  ✓${NC} 数据库配置已设置"
    fi
    if grep -q "JWT_SECRET" .env; then
        echo -e "${GREEN}  ✓${NC} JWT 密钥已设置"
    fi
else
    echo -e "${YELLOW}⚠${NC} .env 文件缺失，请创建"
fi

# 检查源文件
echo -e "${GREEN}✓${NC} 源文件检查："
if [ -f "src/models/userHealthProfileModel.js" ]; then
    echo -e "  ✓ userHealthProfileModel.js"
fi
if [ -f "src/services/personalizedHealthAnalysisService.js" ]; then
    echo -e "  ✓ personalizedHealthAnalysisService.js"
fi
if [ -f "src/routes/personalizedHealthRoutes.js" ]; then
    echo -e "  ✓ personalizedHealthRoutes.js"
fi

echo -e "\n${GREEN}=================================${NC}"
echo -e "${GREEN}✓ 检测完成！系统就绪${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""

# 提示下一步
if ! pgrep -f "node src/app.js" > /dev/null; then
    echo -e "${YELLOW}提示：${NC} 后端服务未运行"
    echo -e "运行 ${BLUE}npm run dev${NC} 启动服务"
    echo ""
fi

echo -e "${BLUE}需要帮助？${NC}"
echo "  📖 查看 BACKEND_TESTING_GUIDE.md"
echo "  💬 VS Code 查询 REST Client 用法"
echo ""
