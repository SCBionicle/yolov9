# resume.ps1

# Set environment variables for memory management and silencing warnings [cite: 1, 2]
# $env:PYTORCH_CUDA_ALLOC_CONF = "expandable_segments:True,max_split_size_mb:128"
$env:PYTORCH_CUDA_ALLOC_CONF = "max_split_size_mb:128"
$env:PYTHONWARNINGS = "ignore"

# Find the most recently modified directory in runs\train\ [cite: 1]
$LatestRun = Get-ChildItem -Path "runs\train" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($LatestRun) {
    # Construct the path to the weights file [cite: 1]
    $LatestWeights = Join-Path $LatestRun.FullName "weights\last.pt"

    if (Test-Path $LatestWeights -PathType Leaf) {
        Write-Host "Found checkpoint: $LatestWeights" -ForegroundColor Green
        Write-Host "Resuming training with optimized parameters..." -ForegroundColor Cyan
        
        # Execute the training script (using backticks ` for line continuation) 
        python train_dual.py `
          --workers 8 `
          --device 0 `
          --batch 16 `
          --data .\training\data.yaml `
          --img 512 `
          --cfg models\detect\yolov9-s.yaml `
          --weights training\yolov9-s.pt `
          --name yolov9-doorbell `
          --epochs 100 `
          --save-period 5 `
          --patience 15 `
          --resume $LatestWeights
    } else {
        Write-Host "Error: No checkpoint found at $LatestWeights" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Error: No training runs found in runs\train\" -ForegroundColor Red
    exit 1
}