#!/usr/bin/env bash

# setup.sh - Setup script for Newsbulous
rm -rf venv #! possibly need to remove this
echo "Just ran rm -rf venv"

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages with color and emojis using Python
function print_message() {
    venv/bin/python - <<END
import sys
from colorama import init, Fore, Style
import emoji

init(autoreset=True)

message = "${1}"
color = "${2}"

color_dict = {
    "GREEN": Fore.GREEN,
    "YELLOW": Fore.YELLOW,
    "BLUE": Fore.BLUE,
    "MAGENTA": Fore.MAGENTA,
    "CYAN": Fore.CYAN,
    "RED": Fore.RED,
    "RESET": Fore.RESET
}

print(color_dict.get(color, Fore.WHITE) + emoji.emojize(message))
END
}

# Start of the setup script
echo "🚀 Welcome to the Newsbulous Setup!"
echo "🔧 Initializing environment setup..."

# Step 1: Create Python virtual environment using Python 3.12
echo "🛠️ Creating Python virtual environment with Python 3.12..."
python3.12 -m venv venv

# Step 2: Activate the virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Step 3: Upgrade pip
echo "⬆️ Upgrading pip..."
pip install --upgrade pip

# Step 4: Install colorama and emoji first
echo "📦 Installing CLI enhancements (colorama, emoji)..."
pip install colorama==0.4.6 emoji==2.3.0

# Now define and use print_message
print_message "🎉 Successfully installed colorama and emoji!" "GREEN"
print_message "📦 Installing remaining project dependencies..." "GREEN"

# Step 5: Install remaining dependencies from requirements.txt
pip install -r requirements.txt

print_message "📁 Creating necessary directories..." "GREEN"
# Step 6: Create necessary directories if they don't exist
mkdir -p templates static

# Step 7: Create sources.json with provided content if it doesn't exist
if [ ! -f "sources.json" ]; then
    print_message "📰 Setting up sources.json..." "GREEN"
    cat <<EOL > sources.json
{
    "CNN": {
        "rss": [
            "http://rss.cnn.com/rss/cnn_latest.rss",
            "http://rss.cnn.com/rss/money_latest.rss",
            "http://rss.cnn.com/rss/edition_world.rss",
            "http://rss.cnn.com/rss/edition.xml"
        ]
    },
    "CNBC": {
        "rss": [
            "https://www.cnbc.com/id/100003114/device/rss/rss.html",
            "https://www.cnbc.com/id/100727362/device/rss/rss.html",
            "https://www.cnbc.com/id/10000664/device/rss/rss.html",
            "https://www.cnbc.com/id/10001147/device/rss/rss.html",
            "https://www.cnbc.com/id/15839135/device/rss/rss.html",
            "https://www.cnbc.com/id/20910258/device/rss/rss.html",
            "https://www.cnbc.com/id/15839069/device/rss/rss.html",
            "http://www.cnbc.com/id/20409666/device/rss/rss.html"
        ]
    },
    "CBN": {
        "rss": [
            "https://www1.cbn.com/rss-cbn-articles-cbnnews.xml",
            "https://www1.cbn.com/rss-cbn-news-finance.xml"
        ]
    }
}
EOL
else
    print_message "📰 sources.json already exists. Skipping creation." "YELLOW"
fi

# Step 8: Create app.py if it doesn't exist
if [ ! -f "app.py" ]; then
    print_message "📄 Creating app.py..." "GREEN"
    cat <<EOL > app.py
from flask import Flask, render_template, jsonify
from apscheduler.schedulers.background import BackgroundScheduler
import feedparser
import json
import os

app = Flask(__name__)

HEADLINES = []

def fetch_headlines():
    global HEADLINES
    HEADLINES = []

    with open('sources.json', 'r') as f:
        sources = json.load(f)

    for source, details in sources.items():
        for rss_url in details.get('rss', []):
            try:
                feed = feedparser.parse(rss_url)
                for entry in feed.entries:
                    if 'title' in entry:
                        HEADLINES.append(entry.title.strip())
            except Exception as e:
                print(f"Error fetching from {rss_url}: {e}")

def update_headlines():
    fetch_headlines()

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/headlines')
def get_headlines():
    return jsonify(HEADLINES)

if __name__ == '__main__':
    scheduler = BackgroundScheduler()
    scheduler.add_job(update_headlines, 'interval', hours=1)
    scheduler.start()
    # Fetch headlines at startup
    update_headlines()
    try:
        app.run(debug=True)
    except (KeyboardInterrupt, SystemExit):
        scheduler.shutdown()
EOL
else
    print_message "📄 app.py already exists. Skipping creation." "YELLOW"
fi

# Step 9: Create index.html if it doesn't exist
if [ ! -f "templates/index.html" ]; then
    print_message "📄 Creating templates/index.html..." "GREEN"
    cat <<EOL > templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Newsbulous - Calming News Cloud</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='styles.css') }}">
</head>
<body>
    <div class="cloud-container">
        <div class="news-cloud" id="newsCloud">Loading headlines...</div>
    </div>

    <script src="{{ url_for('static', filename='scripts.js') }}"></script>
</body>
</html>
EOL
else
    print_message "📄 templates/index.html already exists. Skipping creation." "YELLOW"
fi

# Step 10: Create styles.css if it doesn't exist
if [ ! -f "static/styles.css" ]; then
    print_message "🎨 Creating static/styles.css..." "GREEN"
    cat <<EOL > static/styles.css
body {
    margin: 0;
    padding: 0;
    font-family: 'Helvetica Neue', Arial, sans-serif;
    background: linear-gradient(to bottom, #f0f9ff, #cbebff, #a6ddff);
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.cloud-container {
    width: 80%;
    display: flex;
    justify-content: center;
    align-items: center;
}

.news-cloud {
    font-size: 2rem;
    color: #333;
    max-width: 100%;
    text-align: center;
    padding: 20px;
    border-radius: 10px;
    background: rgba(255, 255, 255, 0.8);
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    animation: fadeInOut 6s infinite;
    transition: opacity 1s ease-in-out;
}

@keyframes fadeInOut {
    0% { opacity: 0; }
    10% { opacity: 1; }
    90% { opacity: 1; }
    100% { opacity: 0; }
}
EOL
else
    print_message "🎨 static/styles.css already exists. Skipping creation." "YELLOW"
fi

# Step 11: Create scripts.js if it doesn't exist
if [ ! -f "static/scripts.js" ]; then
    print_message "💻 Creating static/scripts.js..." "GREEN"
    cat <<EOL > static/scripts.js
document.addEventListener('DOMContentLoaded', () => {
    const newsCloud = document.getElementById('newsCloud');
    let headlines = [];

    // Fetch headlines from the server
    async function loadHeadlines() {
        try {
            const response = await fetch('/headlines');
            headlines = await response.json();
            if (headlines.length === 0) {
                headlines = ["No headlines found. Please check back later."];
            }
            displayNextHeadline();
        } catch (error) {
            console.error('Error fetching headlines:', error);
            headlines = ["Error fetching headlines."];
            displayNextHeadline();
        }
    }

    function displayNextHeadline() {
        if (headlines.length === 0) return;
        // Pick a random headline
        const randomIndex = Math.floor(Math.random() * headlines.length);
        const headline = headlines[randomIndex];

        newsCloud.textContent = headline;

        // Headlines switch every 6 seconds (based on CSS animation timing)
        setTimeout(displayNextHeadline, 6000);
    }

    loadHeadlines();
});
EOL
else
    print_message "💻 static/scripts.js already exists. Skipping creation." "YELLOW"
fi

# Step 12: Create requirements.txt if it doesn't exist
if [ ! -f "requirements.txt" ]; then
    print_message "📄 Creating requirements.txt..." "GREEN"
    cat <<EOL > requirements.txt
Flask==2.3.2
APScheduler==3.10.4
feedparser==6.0.10
colorama==0.4.6
emoji==2.3.0
EOL
else
    print_message "📄 requirements.txt already exists. Skipping creation." "YELLOW"
fi

# Step 13: Final Message
print_message "🎉 Setup complete! Launching Newsbulous..." "CYAN"

# Step 14: Run the Flask application using the virtual environment's python
venv/bin/python app.py
