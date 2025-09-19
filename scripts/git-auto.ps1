Write-Host "🌀 Git Automation Tool (PowerShell)" -ForegroundColor Cyan
Write-Host "Simplifying Git workflows for beginners and casual developers" -ForegroundColor Cyan
Write-Host ""

# Check for status flag
if ($args[0] -eq "--status") {
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "🛑 Git not installed." -ForegroundColor Red
        exit 1
    }
    try {
        git rev-parse --git-dir | Out-Null
    } catch {
        Write-Host "🛑 Not in a Git repository." -ForegroundColor Red
        exit 1
    }
    $branch = git branch --show-current 2>$null
    if (!$branch) {
        $branch = git symbolic-ref --short HEAD 2>$null
    }
    Write-Host "🌿 Current branch: $branch" -ForegroundColor Green
    Write-Host "📊 Status:" -ForegroundColor Yellow
    $statusLines = git status --porcelain
    if ($statusLines) {
        foreach ($line in $statusLines) {
            $status = $line.Substring(0, 2)
            $file = $line.Substring(3)
            switch ($status) {
                "?? " { Write-Host "📄 Untracked: $file" -ForegroundColor Gray }
                "M  " { Write-Host "✏️ Modified: $file" -ForegroundColor Yellow }
                "A  " { Write-Host "✅ Staged: $file" -ForegroundColor Green }
                "D  " { Write-Host "🗑️ Deleted: $file" -ForegroundColor Red }
                "R  " { Write-Host "🔄 Renamed: $file" -ForegroundColor Blue }
                default { Write-Host "❓ Other: $file ($status)" -ForegroundColor Magenta }
            }
        }
    } else {
        Write-Host "✅ Working tree clean." -ForegroundColor Green
    }
    exit 0
}

# Check for branch flag
if ($args[0] -eq "--branch") {
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "🛑 Git not installed." -ForegroundColor Red
        exit 1
    }
    try {
        git rev-parse --git-dir | Out-Null
    } catch {
        Write-Host "🛑 Not in a Git repository." -ForegroundColor Red
        exit 1
    }
    switch ($args[1]) {
        "list" {
            Write-Host "🌿 Branches:" -ForegroundColor Green
            git branch -a
        }
        "switch" {
            if (!$args[2]) {
                Write-Host "🛑 Usage: --branch switch <branch-name>" -ForegroundColor Red
                exit 1
            }
            Write-Host "🔄 Switching to branch $($args[2])..." -ForegroundColor Yellow
            try {
                git checkout $args[2]
                Write-Host "✅ Switched to $($args[2])." -ForegroundColor Green
            } catch {
                Write-Host "🛑 Failed to switch to $($args[2])." -ForegroundColor Red
                exit 1
            }
        }
        "create" {
            if (!$args[2]) {
                Write-Host "🛑 Usage: --branch create <branch-name>" -ForegroundColor Red
                exit 1
            }
            Write-Host "🆕 Creating and switching to branch $($args[2])..." -ForegroundColor Yellow
            try {
                git checkout -b $args[2]
                Write-Host "✅ Created and switched to $($args[2])." -ForegroundColor Green
            } catch {
                Write-Host "🛑 Failed to create $($args[2])." -ForegroundColor Red
                exit 1
            }
        }
        default {
            Write-Host "🛑 Usage: --branch list|switch <name>|create <name>" -ForegroundColor Red
            exit 1
        }
    }
    exit 0
}

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

Write-Host "🔄 Pulling latest changes from origin/$branch..." -ForegroundColor Yellow
try {
    git pull --rebase origin $branch
    Write-Host "✅ Pulled successfully." -ForegroundColor Green
} catch {
    Write-Host "🛑 Pull failed. Continuing with push..." -ForegroundColor Red
}

Write-Host "📤 Pushing to origin/$branch..." -ForegroundColor Yellow
try {
    git push origin $branch
    Write-Host "✅ Pushed successfully to origin/$branch!" -ForegroundColor Green
} catch {
    Write-Host "🛑 Push failed. Check your remote configuration or network." -ForegroundColor Red
    exit 1
}