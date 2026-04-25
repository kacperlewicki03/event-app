from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Model danych
class Event(BaseModel):
    title: str
    category: str
    date: str
    location: str

events_db = [
    {"title": "Warsztaty Python z API", "category": "Edukacja", "date": "20 Maj 2026", "location": "Online"},
    {"title": "Spotkanie przy kawie", "category": "Integracja", "date": "22 Maj 2026", "location": "Kawiarnia 'KOD'"},
    {"title": "Mecz piłki nożnej", "category": "Sport", "date": "25 Maj 2026", "location": "Orlik Akademicki"}
]

@app.get("/events", response_model=List[Event])
async def get_events():
    return events_db

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)