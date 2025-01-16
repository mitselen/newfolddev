# syntax=docker/dockerfile:1

# Use the latest compatible Python version.
ARG PYTHON_VERSION=3.12.1
FROM python:${PYTHON_VERSION}-slim as base

# Prevent Python from writing pyc files and enable unbuffered logging.
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container.
WORKDIR /app

# Create a non-privileged user.
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Copy and install dependencies.
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container.
COPY . .

# Switch to the non-privileged user.
USER appuser

# Expose the port that the application will use.
EXPOSE 8000

# Run the application using Uvicorn.
CMD ["python3", "-m", "uvicorn", "app:app", "--host=0.0.0.0", "--port=8000"]
