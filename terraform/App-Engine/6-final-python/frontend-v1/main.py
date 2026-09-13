from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {
        "service": "frontend",
        "version": "v1",
        "message": "Hello from Frontend V1"
    }