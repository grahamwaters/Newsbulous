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
