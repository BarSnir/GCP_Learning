from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {
        "service": "worker",
        "version": "v1",
        "message": "Worker is alive"
    }

@app.get("/job")
def job():
    return {
        "status": "processed",
        "message": "Fake background job completed"
    }