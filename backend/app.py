from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.config.settings import settings
from backend.api.routes import auth, chat, voice, memory, skills

def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        openapi_url=f"{settings.API_V1_STR}/openapi.json"
    )

    # Set all CORS enabled origins
    if settings.BACKEND_CORS_ORIGINS:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
    
    # Include Routers
    app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["auth"])
    app.include_router(chat.router, prefix=f"{settings.API_V1_STR}/chat", tags=["chat"])
    app.include_router(voice.router, prefix=f"{settings.API_V1_STR}/voice", tags=["voice"])
    app.include_router(memory.router, prefix=f"{settings.API_V1_STR}/memory", tags=["memory"])
    app.include_router(skills.router, prefix=f"{settings.API_V1_STR}/skills", tags=["skills"])

    # WebSocket Route
    from backend.api.ws.stream import websocket_endpoint
    app.add_api_websocket_route(f"{settings.API_V1_STR}/ws/stream", websocket_endpoint)

    @app.on_event("startup")
    async def startup_event():
        from backend.db.session import init_db_engine
        await init_db_engine()

    return app

app = create_app()
