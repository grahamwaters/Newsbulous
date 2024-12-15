#!/usr/bin/env bash

# setup.sh - Setup script for Newsbulous

# Exit immediately if a command exits with a non-zero status
set -e
brew install emoji colorama
# Function to print messages with emojis using Python
function print_message() {
    python3.12 - <<END
import sys
import emoji

message = "${1}"
emoji_message = emoji.emojize(message)

print(emoji_message)
END
}

# Start of the setup script
print_message "🚀 Welcome to the Newsbulous Setup!" ":rocket:"
print_message "🔧 Initializing environment setup..." ":wrench:"

# Step 1: Create Python virtual environment using Python 3.12
print_message "🛠️ Creating Python virtual environment with Python 3.12..." ":hammer_and_wrench:"
python3.12 -m venv venv

# Step 2: Activate the virtual environment
print_message "🔄 Activating virtual environment..." ":arrows_counterclockwise:"
source venv/bin/activate

# Step 3: Upgrade pip
print_message "⬆️ Upgrading pip..." ":arrow_up:"
pip install --upgrade pip

# Step 4: Install dependencies from requirements.txt
print_message "📦 Installing project dependencies..." ":package:"
pip install -r requirements.txt

# Step 5: Create necessary directories if they don't exist
print_message "📁 Creating directories..." ":file_folder:"
mkdir -p templates static

# Step 6: Create sources.json with provided content if it doesn't exist
if [ ! -f "sources.json" ]; then
    print_message "📰 Setting up sources.json..." ":newspaper:"
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
    print_message "📰 sources.json already exists. Skipping creation." ":newspaper:"
fi

# Step 7: Create app.py if it doesn't exist
if [ ! -f "app.py" ]; then
    print_message "📄 Creating app.py..." ":page_facing_up:"
    cat <<EOL > app.py
from flask import Flask, render_template, jsonify
from apscheduler.schedulers.background import BackgroundScheduler
import feedparser
import json
import os
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

app = Flask(__name__)

HEADLINES = []

# Initialize sentiment analyzer
analyzer = SentimentIntensityAnalyzer()

# Define buzzwords and their associated weights for emotional intensity
BUZZWORDS = {
    "Trump": 2,
    "Biden": 2,
    "Jews": 3,
    "ISIS": 3,
    "terrorist": 3,
    "election": 2,
    "immigration": 2,
    "covid": 1,
    "pandemic": 1,
    "economy": 2,
    "war": 3,
    "peace": 1,
    "protest": 2,
    "violence": 3,
    "freedom": 2,
    "rights": 2,
    # Add more buzzwords as needed
}

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
                        headline = entry.title.strip()
                        sentiment = analyze_sentiment(headline)
                        emotional_intensity = analyze_emotional_intensity(headline)
                        HEADLINES.append({
                            'headline': headline,
                            'sentiment': sentiment,
                            'emotional_intensity': emotional_intensity
                        })
            except Exception as e:
                print(f"Error fetching from {rss_url}: {e}")

def analyze_sentiment(text):
    scores = analyzer.polarity_scores(text)
    return scores['compound']  # Compound score ranges from -1 (negative) to +1 (positive)

def analyze_emotional_intensity(text):
    intensity = 0
    for buzzword, weight in BUZZWORDS.items():
        if buzzword.lower() in text.lower():
            intensity += weight
    # Normalize intensity to a scale of 0 to 1
    max_intensity = sum(BUZZWORDS.values())
    normalized_intensity = min(intensity / max_intensity, 1.0)
    return normalized_intensity

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
    print_message "📄 app.py already exists. Skipping creation." ":page_facing_up:"
fi

# Step 8: Create index.html if it doesn't exist
if [ ! -f "templates/index.html" ]; then
    print_message "📄 Creating templates/index.html..." ":page_facing_up:"
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

    <!-- Sentiment Indicator -->
    <div class="sentiment-indicator" id="sentimentIndicator">Neutral</div>

    <script src="{{ url_for('static', filename='scripts.js') }}"></script>
</body>
</html>
EOL
else
    print_message "📄 templates/index.html already exists. Skipping creation." ":page_facing_up:"
fi

# Step 9: Create styles.css if it doesn't exist
if [ ! -f "static/styles.css" ]; then
    print_message "🎨 Creating static/styles.css..." ":artist_palette:"
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
    transition: background 1s ease-in-out;
    position: relative;
    overflow: hidden;
}

/* Background Effects */

body.sunny {
    background: linear-gradient(to bottom, #ffefd5, #ffec8b, #fffacd);
}

body.rainstorm {
    background: linear-gradient(to bottom, #2c3e50, #bdc3c7, #ecf0f1);
    animation: thunder 1s infinite;
}

@keyframes thunder {
    0% { background: linear-gradient(to bottom, #2c3e50, #bdc3c7, #ecf0f1); }
    50% { background: linear-gradient(to bottom, #1c2833, #7f8c8d, #bdc3c7); }
    100% { background: linear-gradient(to bottom, #2c3e50, #bdc3c7, #ecf0f1); }
}

/* Lightning */
body.rainstorm::after {
    content: '';
    position: absolute;
    top: 10%;
    left: 50%;
    width: 2px;
    height: 100px;
    background: white;
    opacity: 0;
    animation: lightning 1.5s infinite;
}

@keyframes lightning {
    0% { opacity: 0; }
    10% { opacity: 1; }
    20% { opacity: 0; }
    70% { opacity: 0; }
    80% { opacity: 1; }
    90% { opacity: 0; }
    100% { opacity: 0; }
}

/* Sunny */
body.sunny::after {
    content: '☀️';
    position: absolute;
    top: 10px;
    right: 10px;
    font-size: 2rem;
    animation: shine 4s infinite;
}

@keyframes shine {
    0% { transform: rotate(0deg); }
    50% { transform: rotate(360deg); }
    100% { transform: rotate(0deg); }
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

/* Sentiment Indicator */

.sentiment-indicator {
    position: absolute;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    padding: 10px 20px;
    border-radius: 20px;
    color: white;
    font-weight: bold;
    font-size: 1rem;
    opacity: 0.8;
    transition: background-color 0.5s ease;
}

/* Sentiment Colors */
.sentiment-positive {
    background-color: darkblue;
}

.sentiment-negative {
    background-color: darkred;
}

.sentiment-neutral {
    background-color: gray;
}
EOL
else
    print_message "🎨 static/styles.css already exists. Skipping creation." ":artist_palette:"
fi

# Step 10: Create scripts.js if it doesn't exist
if [ ! -f "static/scripts.js" ]; then
    print_message "💻 Creating static/scripts.js..." ":computer:"
    cat <<EOL > static/scripts.js
document.addEventListener('DOMContentLoaded', () => {
    const newsCloud = document.getElementById('newsCloud');
    const sentimentIndicator = document.getElementById('sentimentIndicator');
    let headlines = [];

    // Fetch headlines from the server
    async function loadHeadlines() {
        try {
            const response = await fetch('/headlines');
            headlines = await response.json();
            if (headlines.length === 0) {
                headlines = [{"headline": "No headlines found. Please check back later.", "sentiment": 0, "emotional_intensity": 0}];
            }
            displayNextHeadline();
        } catch (error) {
            console.error('Error fetching headlines:', error);
            headlines = [{"headline": "Error fetching headlines.", "sentiment": 0, "emotional_intensity": 0}];
            displayNextHeadline();
        }
    }

    function displayNextHeadline() {
        if (headlines.length === 0) return;
        // Pick a random headline
        const randomIndex = Math.floor(Math.random() * headlines.length);
        const headlineData = headlines[randomIndex];
        const headline = headlineData.headline;
        const sentiment = headlineData.sentiment;
        const emotionalIntensity = headlineData.emotional_intensity;

        // Update the news cloud text
        newsCloud.textContent = headline;

        // Update background based on emotional intensity
        updateBackground(emotionalIntensity);

        // Update sentiment indicator
        updateSentimentIndicator(sentiment);

        // Headlines switch every 6 seconds (based on CSS animation timing)
        setTimeout(displayNextHeadline, 6000);
    }

    function updateBackground(intensity) {
        // intensity is between 0 (calm) and 1 (intense)
        if (intensity >= 0.7) {
            // Rainstorm with lightning
            document.body.classList.add('rainstorm');
            document.body.classList.remove('sunny');
        } else if (intensity >= 0.4) {
            // Cloudy
            document.body.classList.remove('rainstorm', 'sunny');
        } else {
            // Sunny
            document.body.classList.add('sunny');
            document.body.classList.remove('rainstorm');
        }
    }

    function updateSentimentIndicator(sentiment) {
        // sentiment is between -1 (negative) and +1 (positive)
        if (sentiment >= 0.05) {
            sentimentIndicator.textContent = 'Positive';
            sentimentIndicator.classList.remove('sentiment-negative', 'sentiment-neutral');
            sentimentIndicator.classList.add('sentiment-positive');
        } else if (sentiment <= -0.05) {
            sentimentIndicator.textContent = 'Negative';
            sentimentIndicator.classList.remove('sentiment-positive', 'sentiment-neutral');
            sentimentIndicator.classList.add('sentiment-negative');
        } else {
            sentimentIndicator.textContent = 'Neutral';
            sentimentIndicator.classList.remove('sentiment-positive', 'sentiment-negative');
            sentimentIndicator.classList.add('sentiment-neutral');
        }
    }

    loadHeadlines();
});
EOL
else
    print_message "💻 static/scripts.js already exists. Skipping creation." ":computer:"
fi

# Step 11: Create requirements.txt if it doesn't exist
if [ ! -f "requirements.txt" ]; then
    print_message "📄 Creating requirements.txt..." ":page_facing_up:"
    cat <<EOL > requirements.txt
Flask==2.3.2
APScheduler==3.10.4
feedparser==6.0.10
emoji==2.3.0
vaderSentiment==3.3.2
EOL
else
    print_message "📄 requirements.txt already exists. Skipping creation." ":page_facing_up:"
fi

# Step 12: Final Message
print_message "🎉 Setup complete! Launching Newsbulous..." ":tada:"

# Step 13: Run the Flask application using Python 3.12
python3.12 app.py
