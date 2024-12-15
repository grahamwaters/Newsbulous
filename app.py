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
