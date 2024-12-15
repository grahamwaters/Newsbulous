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

    try:
        with open('sources.json', 'r') as f:
            sources = json.load(f)
    except FileNotFoundError:
        print("sources.json not found.")
        return
    except json.JSONDecodeError as e:
        print(f"Error decoding sources.json: {e}")
        return

    for source, details in sources.items():
        for rss_url in details.get('rss', []):
            try:
                feed = feedparser.parse(rss_url)
                if feed.bozo:
                    print(f"Malformed feed at {rss_url}: {feed.bozo_exception}")
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
