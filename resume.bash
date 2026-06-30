#!/bin/bash
#export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128
# Find the most recently modified directory in runs/train/
LATEST_RUN=$(ls -td runs/train/*/ | head -1)
LATEST_WEIGHTS="${LATEST_RUN}weights/last.pt"

if [ -f "$LATEST_WEIGHTS" ]; then
    echo "Found checkpoint: $WEIGHTS"
    echo "Resuming training with optimized parameters..."
    
    PYTHONWARNINGS="ignore" python train_dual.py \
      --workers 2 \
      --device 0 \
      --batch 16 \
      --data ./training/data.yaml \
      --img 512 \
      --cfg models/detect/yolov9-s.yaml \
      --weights training/yolov9-s.pt \
      --name yolov9-doorbell \
      --epochs 100 \
      --image-weights \
      --save-period 5 \
      --patience 15 \
      --resume "$LATEST_WEIGHTS"
else
    echo "Error: No checkpoint found at $WEIGHTS"
    exit 1
fi
