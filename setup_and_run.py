import os
import subprocess
import json

def create_directories():
    """Creates necessary directories for the project."""
    os.makedirs('static', exist_ok=True)
    os.makedirs('templates', exist_ok=True)  # Ensure the templates directory is created

def create_files():
    """Creates necessary files with initial content."""
    sources_content = {
        "CNN": {
            "rss": ["http://rss.cnn.com/rss/cnn_latest.rss",
                    "http://rss.cnn.com/rss/money_latest.rss",
                    "http://rss.cnn.com/rss/edition_world.rss",
                    "http://rss.cnn.com/rss/edition.xml"]
        },
        "CNBC": {
            "rss": ["https://www.cnbc.com/id/100003114/device/rss/rss.html",
                    "https://www.cnbc.com/id/100727362/device/rss/rss.html",
                    "https://www.cnbc.com/id/10000664/device/rss/rss.html",
                    "https://www.cnbc.com/id/10001147/device/rss/rss.html",
                    "https://www.cnbc.com/id/15839135/device/rss/rss.html",
                    "https://www.cnbc.com/id/20910258/device/rss/rss.html",
                    "https://www.cnbc.com/id/15839069/device/rss/rss.html",
                    "http://www.cnbc.com/id/20409666/device/rss/rss.html"]
        },
        "CBN": {
            "rss": ["https://www1.cbn.com/rss-cbn-articles-cbnnews.xml",
                    "https://www1.cbn.com/rss-cbn-news-finance.xml"]
        },
        # Add additional sources as needed
    }
    with open('sources.json', 'w') as file:
        json.dump(sources_content, file, indent=4)

    flask_app_content = """
from flask import Flask, render_template
import feedparser
from wordcloud import WordCloud
import json
import os
from apscheduler.schedulers.background import BackgroundScheduler

app = Flask(__name__)

def fetch_news():
    with open('sources.json', 'r') as file:
        sources = json.load(file)
    headlines = []
    for source, details in sources.items():
        for url in details['rss']:
            feed = feedparser.parse(url)
            headlines.extend(entry['title'] for entry in feed.entries)
    return headlines

def generate_word_cloud(headlines):
    text = ' '.join(headlines)
    wordcloud = WordCloud(width=800, height=400).generate(text)
    wordcloud.to_file('static/wordcloud.png')

def update_news():
    headlines = fetch_news()
    generate_word_cloud(headlines)

@app.route('/')
def home():
    if not os.path.exists('static/wordcloud.png'):
        update_news()
    return render_template('index.html')

if __name__ == '__main__':
    scheduler = BackgroundScheduler()
    scheduler.add_job(update_news, 'interval', hours=1)
    scheduler.start()
    app.run(debug=True)
    """
    with open('app.py', 'w') as file:
        file.write(flask_app_content.strip())

    html_content = """
<!DOCTYPE html>
<html>
<head>
    <title>Newsbulous - News Word Cloud</title>
    <style>
        body { display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f0f0f0; }
        img { max-width: 100%; height: auto; }
    </style>
</head>
<body>
    <img src="{{ url_for('static', filename='wordcloud.png') }}" alt="News Word Cloud">
</body>
</html>
    """
    with open('templates/index.html', 'w') as file:
        file.write(html_content.strip())

def install_dependencies():
    """Installs required Python packages."""
    subprocess.run(['pip', 'install', 'flask', 'feedparser', 'wordcloud', 'matplotlib', 'apscheduler'], check=True)

def main():
    create_directories()
    create_files()
    install_dependencies()
    subprocess.run(['python', 'app.py'])

if __name__ == '__main__':
    main()
