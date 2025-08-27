FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py ./
COPY scripts/copy_env.sh ./
RUN chmod +x copy_env.sh
EXPOSE 5001
CMD ["python", "app.py"]
