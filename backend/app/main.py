from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import sqlite3

app = FastAPI()
conn = sqlite3.connect("events.db", check_same_thread=False)
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    description TEXT,
    category TEXT,
    date TEXT,
    location TEXT,
    latitude REAL,
    longitude REAL
)
""")

conn.commit()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Model danych
class Event(BaseModel):
    id: int | None = None
    title: str
    description: str
    category: str
    date: str
    location: str
    latitude: float
    longitude: float

class EventCreate(BaseModel):
    title: str
    description: str
    category: str
    date: str
    location: str
    latitude: float
    longitude: float

@app.get("/events")
async def get_events():
    cursor.execute("SELECT * FROM events")

    rows = cursor.fetchall()

    events = []

    for row in rows:
        events.append({
            "id": row[0],
            "title": row[1],
            "description": row[2],
            "category": row[3],
            "date": row[4],
            "location": row[5],
            "latitude": row[6],
            "longitude": row[7],
        })

    return events

@app.post("/events")
async def create_event(event: Event):

    cursor.execute("""
    INSERT INTO events (
        title,
        description,
        category,
        date,
        location,
        latitude,
        longitude
    )
    VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (
        event.title,
        event.description,
        event.category,
        event.date,
        event.location,
        event.latitude,
        event.longitude
    ))

    conn.commit()

    return {"message": "event created"}

@app.delete("/events/{event_id}")
async def delete_event(event_id: int):

    cursor.execute(
        "DELETE FROM events WHERE id = ?",
        (event_id,)
    )

    conn.commit()

    return {"message": "deleted"}

@app.put("/events/{event_id}")
async def update_event(event_id: int, event: Event):

    cursor.execute("""
    UPDATE events
    SET
        title = ?,
        description = ?,
        category = ?,
        date = ?,
        location = ?,
        latitude = ?,
        longitude = ?
    WHERE id = ?
    """, (
        event.title,
        event.description,
        event.category,
        event.date,
        event.location,
        event.latitude,
        event.longitude,
        event_id
    ))

    conn.commit()

    return {"message": "updated"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)