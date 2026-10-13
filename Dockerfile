FROM python:3.12-slim
WORKDIR /app
COPY agent ./agent
COPY data ./data
USER 65534:65534
ENTRYPOINT ["python", "-m", "agent"]
