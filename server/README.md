# MyApp API

FastAPI + SQLAlchemy + SQLite。框架阶段数据文件默认为当前工作目录下的 `app.db`（可通过环境变量 `DATABASE_URL` 修改）。

## 环境变量

| 变量 | 说明 |
|------|------|
| `DATABASE_URL` | 默认 `sqlite:///./app.db` |
| `API_KEY` | 非空时，所有业务接口需 `X-API-Key` 请求头 |

复制 `.env.example` 为 `.env` 并按需修改。

## 开发

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
