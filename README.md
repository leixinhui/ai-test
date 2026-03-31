# iPhone 客户端 + Server + DB（框架骨架）

本仓库包含 **SwiftUI iOS 应用**、**FastAPI 后端** 与 **SQLite** 持久化，用于本地联调与迭代。

## 结构

| 路径 | 说明 |
|------|------|
| [`ios/`](ios/) | Xcode 工程 `MyApp.xcodeproj`，SwiftUI 列表 + 异步请求 + `Codable` |
| [`server/`](server/) | FastAPI，`/items` CRUD，OpenAPI：`/docs` |
| [`server/app.db`](server/app.db) | SQLite 数据文件（本地生成，已 `.gitignore`） |

## 后端（FastAPI + SQLite）

```bash
cd server
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env        # 可选：设置 API_KEY 以启用简单鉴权
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- 浏览器打开 <http://127.0.0.1:8000/docs> 调试 API。
- 若设置 `API_KEY`，请求需带请求头 `X-API-Key: <值>`；iOS 在 [`Config/Debug.xcconfig`](ios/Config/Debug.xcconfig) 中配置 `API_KEY`（勿把生产密钥提交进仓库）。
- 生产环境建议把密钥放在环境变量或密钥管理服务中；客户端侧长期应使用 **Keychain** 存敏感令牌，当前骨架用 Info.plist 注入仅便于开发。

## iOS（Xcode）

1. 用 Xcode 打开 [`ios/MyApp.xcodeproj`](ios/MyApp.xcodeproj)。
2. 先启动后端（见上）。
3. **模拟器**：[`ios/Config/Debug.xcconfig`](ios/Config/Debug.xcconfig) 默认 `API_HOST = 127.0.0.1`，可直接访问 Mac 上的 API。
4. **真机**：将同一 Wi‑Fi 下 Mac 的局域网 IP 设为 `API_HOST`，后端使用 `uvicorn ... --host 0.0.0.0`；必要时检查 Mac 防火墙。

## 自动化测试（后端）

```bash
cd server && source .venv/bin/activate && pytest tests/ -v
```

## CI

推送时 GitHub Actions 会安装依赖并运行 `pytest`（见 [`.github/workflows/ci.yml`](.github/workflows/ci.yml)）。

## 上线备忘

- 将 API 部署到云主机或 PaaS，数据库可迁 **PostgreSQL**；客户端 `Release` 配置指向生产域名与 HTTPS。
- App 内测与上架需 Apple Developer Program；详见计划文档中的「部署」步骤。
