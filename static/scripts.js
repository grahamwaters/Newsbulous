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
