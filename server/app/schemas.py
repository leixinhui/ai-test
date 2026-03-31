from datetime import datetime, timezone

from pydantic import BaseModel, ConfigDict, Field, field_serializer


class ItemCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=512)


class ItemRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    created_at: datetime

    @field_serializer("created_at")
    def serialize_created_at(self, value: datetime, _info):
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.isoformat().replace("+00:00", "Z")
