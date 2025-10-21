FROM python:3.11-slim
run apt-get update  
run apt-get install -y git
run git lfs install
run git clone https://github.com/index-tts/index-tts.git
run cd index-tts
run git lfs pull
run pip install -U uv
run uv sync --extra webui
run uv tool install "huggingface-hub[cli,hf_xet]"
run hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints
EXPOSE 7860
CMD ["uv", "run" ,"webui.py"]