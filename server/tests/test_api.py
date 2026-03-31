import os
import tempfile

import pytest
from fastapi.testclient import TestClient

os.environ.setdefault("DATABASE_URL", "sqlite:///:memory:")


@pytest.fixture()
def client():
    from app.database import Base, engine
    from app.main import app

    Base.metadata.create_all(bind=engine)
    with TestClient(app) as c:
        yield c


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_items_crud(client):
    assert client.get("/items").json() == []
    r = client.post("/items", json={"title": "  hi  "})
    assert r.status_code == 200
    body = r.json()
    assert body["title"] == "hi"
    assert "created_at" in body
    listed = client.get("/items").json()
    assert len(listed) == 1
    assert listed[0]["title"] == "hi"
