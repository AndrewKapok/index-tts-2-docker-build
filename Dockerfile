FROM python:3.11-slim

run apt-get update &&\
    apt-get install -y git git-lfs&&\
    git lfs install

WORKDIR /app

RUN git clone https://github.com/index-tts/index-tts.git

WORKDIR /app/index-tts

RUN git lfs pull 

RUN pip install -U uv

RUN uv sync --extra webui

RUN uv tool install "huggingface-hub[cli,hf_xet]" 

RUN uv run hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints

EXPOSE 7860

CMD ["uv", "run" ,"webui.py"]