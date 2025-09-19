echo "🌀 Git Automation Tool (Bash)"
echo "Simplifying Git workflows for beginners and casual developers"
echo ""

if [ "$1" = "--status" ]; then
    if ! command -v git &> /dev/null; then
        echo "🛑 Git not installed."
        exit 1
    fi
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "🛑 Not in a Git repository."
        exit 1
    fi
    branch=$(git branch --show-current 2>/dev/null)
    if [ -z "$branch" ]; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    fi
    echo "🌿 Current branch: $branch"
    echo "📊 Status:"
    git status --porcelain | while read -r line; do
        status=${line:0:2}
        file=${line:3}
        case $status in
            "??") echo "📄 Untracked: $file" ;;
            "M ") echo "✏️ Modified: $file" ;;
            "A ") echo "✅ Staged: $file" ;;
            "D ") echo "🗑️ Deleted: $file" ;;
            "R ") echo "🔄 Renamed: $file" ;;
            *) echo "❓ Other: $file ($status)" ;;
        esac
    done
    if [ -z "$(git status --porcelain)" ]; then
        echo "✅ Working tree clean."
    fi
    exit 0
fi

if [ "$1" = "--branch" ]; then
    if ! command -v git &> /dev/null; then
        echo "🛑 Git not installed."
        exit 1
    fi
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "🛑 Not in a Git repository."
        exit 1
    fi
    case $2 in
        list)
            echo "🌿 Branches:"
            git branch -a
            ;;
        switch)
            if [ -z "$3" ]; then
                echo "🛑 Usage: --branch switch <branch-name>"
                exit 1
            fi
            echo "🔄 Switching to branch $3..."
            if git checkout "$3"; then
                echo "✅ Switched to $3."
            else
                echo "🛑 Failed to switch to $3."
                exit 1
            fi
            ;;
        create)
            if [ -z "$3" ]; then
                echo "🛑 Usage: --branch create <branch-name>"
                exit 1
            fi
            echo "🆕 Creating and switching to branch $3..."
            if git checkout -b "$3"; then
                echo "✅ Created and switched to $3."
            else
                echo "🛑 Failed to create $3."
                exit 1
            fi
            ;;
        *)
            echo "🛑 Usage: --branch list|switch <name>|create <name>"
            exit 1
            ;;
    esac
    exit 0
fi

if [ "$1" = "--stage" ]; then
    if ! command -v git &> /dev/null; then
        echo "🛑 Git not installed."
        exit 1
    fi
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "🛑 Not in a Git repository."
        exit 1
    fi
    files=($(git status --porcelain | awk '{print $2}'))
    if [ ${#files[@]} -eq 0 ]; then
        echo "✅ No changes to stage."
        exit 0
    fi
    echo "📋 Files to stage:"
    for i in "${!files[@]}"; do
        status=$(git status --porcelain "${files[$i]}" | cut -c1-2)
        case $status in
            "??") echo "$((i+1)). 📄 ${files[$i]} (untracked)" ;;
            "M ") echo "$((i+1)). ✏️ ${files[$i]} (modified)" ;;
            "A ") echo "$((i+1)). ✅ ${files[$i]} (staged)" ;;
            "D ") echo "$((i+1)). 🗑️ ${files[$i]} (deleted)" ;;
            *) echo "$((i+1)). ❓ ${files[$i]} ($status)" ;;
        esac
    done
    read -p "Enter numbers to stage (comma-separated) or 'all': " input
    if [ "$input" = "all" ]; then
        git add .
        echo "✅ All files staged."
    else
        IFS=',' read -ra nums <<< "$input"
        for num in "${nums[@]}"; do
            idx=$((num-1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#files[@]} ]; then
                git add "${files[$idx]}"
                echo "✅ Staged: ${files[$idx]}"
            fi
        done
    fi
    exit 0
fi

if ! command -v git &> /dev/null; then
    echo "🛑 Git not installed. Please install Git first."
    exit 1
fi

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "🛑 Not in a Git repository. Run 'git init' to initialize one."
    exit 1
fi

if git diff --quiet && git diff --staged --quiet; then
    echo "✅ No changes to commit. Working tree is clean."
    exit 0
fi

echo "📦 Staging all changes..."
git add .
echo "✅ Changes staged successfully."

read -p "Enter commit message (default: 'update'): " message
message=${message:-"update"}

echo "💾 Committing changes..."
if git commit -m "$message"; then
    echo "✅ Committed successfully."
else
    echo "🛑 Commit failed. Please check for issues."
    exit 1
fi

branch=$(git branch --show-current 2>/dev/null)
if [ -z "$branch" ]; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) 
fi
if [ -z "$branch" ]; then
    echo "🛑 Unable to detect current branch."
    exit 1
fi

echo "🔄 Pulling latest changes from origin/$branch..."
if git pull --rebase origin "$branch"; then
    echo "✅ Pulled successfully."
else
    echo "🛑 Pull failed. Continuing with push..."
fi

echo "📤 Pushing to origin/$branch..."
if git push origin "$branch"; then
    echo "✅ Pushed successfully to origin/$branch!"
else
    echo "🛑 Push failed. Check your remote configuration or network."
    exit 1
fi