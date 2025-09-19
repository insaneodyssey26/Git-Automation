Write-Host "🌀 Git Automation Tool (PowerShell)" -ForegroundColor Cyan
Write-Host "Simplifying Git workflows for beginners and casual developers" -ForegroundColor Cyan
Write-Host ""

if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "🛑 Git not installed. Please install Git first." -ForegroundColor Red
    exit 1
}

try {
    git rev-parse --git-dir | Out-Null
} catch {
    Write-Host "🛑 Not in a Git repository. Run 'git init' to initialize one." -ForegroundColor Red
    exit 1
}

$status = git status --porcelain
if (!$status) {
    Write-Host "✅ No changes to commit. Working tree is clean." -ForegroundColor Green
    exit 0
}

Write-Host "📦 Staging all changes..." -ForegroundColor Yellow
git add .
Write-Host "✅ Changes staged successfully." -ForegroundColor Green

$message = Read-Host "Enter commit message (default: 'update')"
if (!$message) { $message = "update" }

Write-Host "💾 Committing changes..." -ForegroundColor Yellow
try {
    git commit -m $message
    Write-Host "✅ Committed successfully." -ForegroundColor Green
} catch {
    Write-Host "🛑 Commit failed. Please check for issues." -ForegroundColor Red
    exit 1
}

$branch = git branch --show-current 2>$null
if (!$branch) {
    $branch = git symbolic-ref --short HEAD 2>$null  
}
if (!$branch) {
    Write-Host "🛑 Unable to detect current branch." -ForegroundColor Red
    exit 1
}

Write-Host "📤 Pushing to origin/$branch..." -ForegroundColor Yellow
try {
    git push origin $branch
    Write-Host "✅ Pushed successfully to origin/$branch!" -ForegroundColor Green
} catch {
    Write-Host "🛑 Push failed. Check your remote configuration or network." -ForegroundColor Red
    exit 1
}