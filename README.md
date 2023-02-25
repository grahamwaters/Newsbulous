# Newsbulous
The simple and nonintrusive news aggregator.

Enough with the news sites shoving aggressive and highly inflamatory news down your throat. Newsbulous is a simple and nonintrusive news aggregator that lets you read the news without the noise. It's all the others wish they could be. Simple, quiet, and nonbiased. It has no spin because it takes from every source. So, if there's bias, it's not from us. Welcome to Newsbulous.

## Features
The main page is a flask site that shows an animated word cloud. This word cloud evolves and slowly changes updating with headlines from news sites outlined in the sources.json file. That's really all there is to it. It's simple, clean, and it will give you a ten-thousand-foot view of the news. It's not meant to be another 'news' site. It's meant to be a tool to help you get a better idea of what's going on in the world as if you were in the clouds looking down.

## Acknowledgements
This project borrows heavily from the work of [elisemercury](https://github.com/elisemercury/) on the project newscollector. It's a great project and I highly recommend it. I've just added a few features and made it a bit more user friendly.

```python
from newscollector import *

newsletter = NewsCollector()
output = newsletter.create()
```

For now let's use the existing sources.json file. It's a list of news sites that I've found to be reliable. I'll be adding more as I find them. If you have any suggestions, please let me know.

```json
{"CNN":
	{"rss": ["http://rss.cnn.com/rss/cnn_latest.rss",
		 "http://rss.cnn.com/rss/money_latest.rss",
		 "http://rss.cnn.com/rss/edition_world.rss",
		 "http://rss.cnn.com/rss/edition.xml"]},
 "CNBC":
	{"rss": ["https://www.cnbc.com/id/100003114/device/rss/rss.html",
             "https://www.cnbc.com/id/100727362/device/rss/rss.html",
             "https://www.cnbc.com/id/10000664/device/rss/rss.html",
			 "https://www.cnbc.com/id/10001147/device/rss/rss.html",
			 "https://www.cnbc.com/id/15839135/device/rss/rss.html",
			 "https://www.cnbc.com/id/20910258/device/rss/rss.html",
			 "https://www.cnbc.com/id/15839069/device/rss/rss.html",
			 "http://www.cnbc.com/id/20409666/device/rss/rss.html"]},
 "CBN":
	{"rss": ["https://www1.cbn.com/rss-cbn-articles-cbnnews.xml",
		 "https://www1.cbn.com/rss-cbn-news-finance.xml"]},
 "Financial Times":
     {"rss": ["https://www.ft.com/rss/home/uk"]},
 "MarketWatch":
	{"rss": ["http://feeds.marketwatch.com/marketwatch/topstories/",
			 "http://feeds.marketwatch.com/marketwatch/marketpulse/"]},
 "Fortune":
	{"rss": ["https://fortune.com/feed"]},

 "Wall Street Journal":
	{"rss": ["https://feeds.a.dj.com/rss/WSJcomUSBusiness.xml",
			 "https://feeds.a.dj.com/rss/RSSMarketsMain.xml",
			 "https://feeds.a.dj.com/rss/RSSWSJD.xml"]},

 "Business Standard":
	{"rss": ["https://www.business-standard.com/rss/home_page_top_stories.rss",
			 "https://www.business-standard.com/rss/markets-106.rss",
             "https://www.business-standard.com/rss/latest.rss",
             "https://www.business-standard.com/rss/companies-101.rss",
			 "https://www.business-standard.com/rss/finance-103.rss"]},
 "Business Daily":
	{"rss": ["https://www.businessdailyafrica.com/latestrss.rss"]},

 "Daily Telegraph":
	{"rss": ["https://www.dailytelegraph.com.au/business/rss",
			 "https://www.dailytelegraph.com.au/business/breaking-news/rss"]},

 "The Guardian":
	{"rss": ["https://www.theguardian.com/uk/business/rss",
			 "https://www.theguardian.com/business/economics/rss",
			 "https://www.theguardian.com/business/stock-markets/rss"]},

 "Skynews":
	{"rss": ["http://feeds.skynews.com/feeds/rss/business.xml"]},

 "Wall Street Survivor":
    {"rss": ["https://blog.wallstreetsurvivor.com/feed/"]},

 "Fortune":
	{"rss": ["https://fortune.com/feed"]},

 "Seeking Alpha":
    {"rss": ["https://seekingalpha.com/feed.xml",
             "https://seekingalpha.com/market_currents.xml"]},
 "Reddit":
	{"rss": ["https://www.reddit.com/r/stocks/.rss",
			 "https://www.reddit.com/r/StockMarket/.rss"]},

 "New York Times":
	{"rss": ["https://rss.nytimes.com/services/xml/rss/nyt/Economy.xml",
			 "https://rss.nytimes.com/services/xml/rss/nyt/Business.xml"]},

 "Yahoo Finance":
	{"rss": ["https://finance.yahoo.com/rss/topstories",
			 "https://finance.yahoo.com/news/rssindex"]},

 "Investing.com":
	{"rss": ["https://www.investing.com/rss/news.rss",
             "https://www.investing.com/rss/market_overview.rss",
			 "https://www.investing.com/rss/stock_Stocks.rss",
			 "https://www.investing.com/rss/news_14.rss",
			 "https://www.investing.com/rss/news_25.rss",
			 "https://www.investing.com/rss/news_95.rss"]}
}
```
