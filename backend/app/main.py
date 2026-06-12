from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import sqlite3
import hashlib
import secrets

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

cursor.execute("""
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    salt TEXT NOT NULL,
    session_token TEXT
)
""")

cursor.execute("PRAGMA table_info(events)")
event_columns = [column[1] for column in cursor.fetchall()]

if "user_id" not in event_columns:
    cursor.execute("ALTER TABLE events ADD COLUMN user_id INTEGER")
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
    
class UserRegister(BaseModel):
    username: str
    email: str
    password: str


class UserLogin(BaseModel):
    email: str
    password: str

def hash_password(password: str, salt: str) -> str:
    return hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt.encode("utf-8"),
        100_000
    ).hex()


def get_current_user(authorization: str | None = Header(default=None)):
    if authorization is None or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Brak autoryzacji")

    token = authorization.replace("Bearer ", "", 1)

    cursor.execute(
        "SELECT id, username, email FROM users WHERE session_token = ?",
        (token,)
    )

    user = cursor.fetchone()

    if user is None:
        raise HTTPException(status_code=401, detail="Nieprawidłowa sesja")

    return {
        "id": user[0],
        "username": user[1],
        "email": user[2],
    }

@app.post("/register")
async def register_user(user: UserRegister):
    username = user.username.strip()
    email = user.email.lower().strip()
    password = user.password

    if len(username) < 3:
        raise HTTPException(
            status_code=400,
            detail="Nazwa użytkownika musi mieć minimum 3 znaki"
        )

    if "@" not in email:
        raise HTTPException(
            status_code=400,
            detail="Podaj poprawny adres e-mail"
        )

    if len(password) < 6:
        raise HTTPException(
            status_code=400,
            detail="Hasło musi mieć minimum 6 znaków"
        )

    salt = secrets.token_hex(16)
    password_hash = hash_password(password, salt)
    session_token = secrets.token_hex(32)

    try:
        cursor.execute("""
            INSERT INTO users (username, email, password_hash, salt, session_token)
            VALUES (?, ?, ?, ?, ?)
        """, (
            username,
            email,
            password_hash,
            salt,
            session_token,
        ))

        conn.commit()

    except sqlite3.IntegrityError:
        raise HTTPException(
            status_code=400,
            detail="Użytkownik z takim adresem e-mail już istnieje"
        )

    user_id = cursor.lastrowid

    return {
        "token": session_token,
        "user": {
            "id": user_id,
            "username": username,
            "email": email,
        }
    }

@app.post("/login")
async def login_user(user: UserLogin):
    email = user.email.lower().strip()
    password = user.password

    cursor.execute("""
        SELECT id, username, email, password_hash, salt
        FROM users
        WHERE email = ?
    """, (email,))

    row = cursor.fetchone()

    if row is None:
        raise HTTPException(
            status_code=401,
            detail="Nieprawidłowy e-mail lub hasło"
        )

    user_id, username, db_email, db_password_hash, salt = row

    password_hash = hash_password(password, salt)

    if password_hash != db_password_hash:
        raise HTTPException(
            status_code=401,
            detail="Nieprawidłowy e-mail lub hasło"
        )

    session_token = secrets.token_hex(32)

    cursor.execute(
        "UPDATE users SET session_token = ? WHERE id = ?",
        (session_token, user_id)
    )

    conn.commit()

    return {
        "token": session_token,
        "user": {
            "id": user_id,
            "username": username,
            "email": db_email,
        }
    }

@app.post("/logout")
async def logout_user(current_user=Depends(get_current_user)):
    cursor.execute(
        "UPDATE users SET session_token = NULL WHERE id = ?",
        (current_user["id"],)
    )

    conn.commit()

    return {"message": "logged out"}

@app.get("/my-events")
async def get_my_events(current_user=Depends(get_current_user)):
    cursor.execute("""
        SELECT
            id,
            title,
            description,
            category,
            date,
            location,
            latitude,
            longitude,
            user_id
        FROM events
        WHERE user_id = ?
        ORDER BY id DESC
    """, (current_user["id"],))

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
            "user_id": row[8],
        })

    return events

@app.post("/my-events")
async def create_my_event(event: Event, current_user=Depends(get_current_user)):
    cursor.execute("""
        INSERT INTO events (
            title,
            description,
            category,
            date,
            location,
            latitude,
            longitude,
            user_id
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        event.title,
        event.description,
        event.category,
        event.date,
        event.location,
        event.latitude,
        event.longitude,
        current_user["id"],
    ))

    conn.commit()

    return {"message": "event created"}


@app.put("/my-events/{event_id}")
async def update_my_event(
    event_id: int,
    event: Event,
    current_user=Depends(get_current_user)
):
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
        WHERE id = ? AND user_id = ?
    """, (
        event.title,
        event.description,
        event.category,
        event.date,
        event.location,
        event.latitude,
        event.longitude,
        event_id,
        current_user["id"],
    ))

    conn.commit()

    if cursor.rowcount == 0:
        raise HTTPException(
            status_code=404,
            detail="Nie znaleziono wydarzenia użytkownika"
        )

    return {"message": "updated"}

@app.delete("/my-events/{event_id}")
async def delete_my_event(event_id: int, current_user=Depends(get_current_user)):
    cursor.execute(
        "DELETE FROM events WHERE id = ? AND user_id = ?",
        (event_id, current_user["id"])
    )

    conn.commit()

    if cursor.rowcount == 0:
        raise HTTPException(
            status_code=404,
            detail="Nie znaleziono wydarzenia użytkownika"
        )

    return {"message": "deleted"}





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