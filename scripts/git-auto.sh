echo "🌀 Git Automation Tool (Bash)"
echo "Simplifying Git workflows for beginners and casual developers"
echo ""

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