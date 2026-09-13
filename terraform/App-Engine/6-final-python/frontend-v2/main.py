from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {
        "service": "frontend",
        "version": "v2",
        "message": "Hello from Frontend V2"
    }