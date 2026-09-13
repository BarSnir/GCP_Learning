from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {
        "service": "api",
        "version": "v1",
        "message": "Hello from API"
    }