FROM python:3.11-slim
WORKDIR /app
COPY app.py ./
RUN pip install flask flask-cors
EXPOSE 5001
CMD ["python", "app.py"]
