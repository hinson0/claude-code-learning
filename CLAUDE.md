# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 语言要求

**始终用中文回复用户**，包括所有解释、说明、错误信息和代码注释。

## 技术栈规范

### Python 版本
- 使用 **Python 3.12+** 语法

### FastAPI（最新版本）
- 使用 `Annotated` 类型注解配合 `Depends`、`Query`、`Body` 等参数
- 使用 `str | None` 代替 `Optional[str]`（Python 3.10+ union 语法）
- 路由函数优先使用 `async def`

```python
from typing import Annotated
from fastapi import FastAPI, Depends, Query

@app.get("/items/")
async def read_items(
    q: Annotated[str | None, Query(max_length=50)] = None,
):
    ...
```

### Pydantic V2（最新版本）
- 使用 `@field_validator` 代替已废弃的 `@validator`
- 使用 `@model_validator` 代替 `@root_validator`
- 验证器必须加 `@classmethod`
- 使用 `mode='before'` / `mode='after'` / `mode='wrap'` 控制验证时机

```python
from pydantic import BaseModel, field_validator, model_validator, ValidationInfo

class User(BaseModel):
    name: str
    age: int

    @field_validator('age', mode='before')
    @classmethod
    def validate_age(cls, v: int, info: ValidationInfo) -> int:
        if v < 0:
            raise ValueError("年龄不能为负数")
        return v

    @model_validator(mode='after')
    def check_consistency(self) -> 'User':
        return self
```

### Python 3.12+ 语法
- 类型别名使用 `type` 关键字：`type Vector = list[float]`
- Union 类型使用 `X | Y` 语法（无需 `from __future__ import annotations`）
- 使用 `typing.override` 装饰器标记重写方法

## 包管理（uv）

- **始终使用 uv**，禁止直接使用 pip
- 安装依赖：`uv add <package>`
- 安装开发依赖：`uv add --dev <package>`
- 同步依赖：`uv sync`
- 运行命令：`uv run <command>`
- 初始化项目：`uv init`

## 项目目录结构

```
项目根/
├── src/
│   └── app/
│       ├── main.py          # FastAPI 应用入口
│       ├── api/             # 路由层
│       │   └── v1/
│       │       └── routes/
│       ├── core/            # 配置、依赖、安全
│       │   ├── config.py
│       │   └── deps.py
│       ├── models/          # SQLAlchemy/ORM 模型
│       ├── schemas/         # Pydantic schemas
│       ├── services/        # 业务逻辑层
│       └── repositories/   # 数据访问层
├── tests/
├── pyproject.toml
└── uv.lock
```

## 常用命令

- 启动开发服务器：`uv run fastapi dev src/app/main.py`
- 运行测试：`uv run pytest`
- 运行测试（含覆盖率）：`uv run pytest --cov`
- 代码格式化：`uv run ruff format .`
- 代码检查：`uv run ruff check .`
- 类型检查：`uv run mypy src/`

## 项目分层规范

- **routes/**：只处理 HTTP 请求/响应，调用 service
- **services/**：业务逻辑，调用 repository
- **repositories/**：数据访问，只与数据库交互
- **schemas/**：Pydantic 模型，用于请求/响应验证
- **models/**：ORM 模型，对应数据库表

## 测试规范

- 使用 `pytest` + `pytest-asyncio`
- 使用 `httpx.AsyncClient` 作为异步测试客户端
- 测试文件放在 `tests/` 目录，命名 `test_*.py`
- 最低覆盖率 80%
