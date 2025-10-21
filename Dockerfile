FROM python:3.11-slim
run apt-get update &&\
    apt-get install -y git git-lfs&&\
    git lfs install &&\
    git clone https://github.com/index-tts/index-tts.git &&\
    git lfs pull &&\
    cd index-tts &&\
    pip install -U uv &&\
    uv sync --extra webui &&\
    uv tool install "huggingface-hub[cli,hf_xet]" &&\
    hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints
EXPOSE 7860
CMD ["uv", "run" ,"webui.py"]