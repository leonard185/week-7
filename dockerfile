# Use official Python image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy files to the container
COPY . /app

# Install dependencies
RUN pip install -r requirements.txt

# Expose app port
EXPOSE 5000

# Start app
CMD ["python", "app.py"]
