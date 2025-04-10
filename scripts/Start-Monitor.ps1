Write-Host "Starting WSL monitoring setup..." -ForegroundColor Cyan

# First, make sure the bash scripts are executable in WSL
wsl -d rhel9 chmod +x /mnt/c/Users/sgallego/Downloads/GIT/ee-containers/scripts/start_monitor.sh
wsl -d rhel9 chmod +x /mnt/c/Users/sgallego/Downloads/GIT/ee-containers/scripts/open_terminal.sh

# Kill any existing tmux sessions
Write-Host "Cleaning up any existing tmux sessions..." -ForegroundColor Yellow
wsl -d rhel9 tmux kill-session -t podman-monitor 2>/dev/null

# Start a fresh tmux session
Write-Host "Creating new monitoring session..." -ForegroundColor Green
wsl -d rhel9 tmux new-session -d -s podman-monitor
Start-Sleep -Seconds 1

# Check if session was created
$sessionExists = wsl -d rhel9 tmux has-session -t podman-monitor 2>/dev/null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Session created successfully" -ForegroundColor Green
    
    # Configure the session
    wsl -d rhel9 tmux send-keys -t podman-monitor "clear" C-m
    wsl -d rhel9 tmux send-keys -t podman-monitor "echo '=== PODMAN MONITORING DASHBOARD ==='" C-m
    wsl -d rhel9 tmux send-keys -t podman-monitor "echo 'Current images:'" C-m
    wsl -d rhel9 tmux send-keys -t podman-monitor "podman images" C-m
    
    # Open Windows Terminal to connect to the session
    Write-Host "Opening Windows Terminal to connect..." -ForegroundColor Cyan
    Start-Process wt.exe -ArgumentList "-d", ".", "wsl", "-d", "rhel9", "bash", "-c", "`"tmux attach -t podman-monitor`""
} else {
    Write-Host "✕ Failed to create tmux session!" -ForegroundColor Red
}

Write-Host "`nTo manually connect to the monitoring session:" -ForegroundColor Yellow
Write-Host "1. Open Windows Terminal" -ForegroundColor Yellow
Write-Host "2. Enter WSL with: wsl -d rhel9" -ForegroundColor Yellow
Write-Host "3. Connect with: tmux attach -t podman-monitor" -ForegroundColor Yellow