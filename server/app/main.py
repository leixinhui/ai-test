from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.database import Base, engine, get_db
from app.models import Item
from app.schemas import ItemCreate, ItemRead


@asynccontextmanager
async def lifespan(_: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(title="MyApp API", version="0.1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def verify_api_key(x_api_key: str | None = Header(default=None, alias="X-API-Key")):
    settings = get_settings()
    if not settings.api_key:
        return
    if x_api_key != settings.api_key:
        raise HTTPException(status_code=401, detail="Invalid or missing API key")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/items", response_model=list[ItemRead])
def list_items(
    db: Session = Depends(get_db),
    _: None = Depends(verify_api_key),
):
    stmt = select(Item).order_by(Item.created_at.desc())
    return list(db.scalars(stmt).all())


@app.post("/items", response_model=ItemRead)
def create_item(
    body: ItemCreate,
    db: Session = Depends(get_db),
    _: None = Depends(verify_api_key),
):
    row = Item(title=body.title.strip())
    db.add(row)
    db.commit()
    db.refresh(row)
    return row
