import scrapy
from scrapy.crawler import CrawlerProcess

wprice = 0
img = ''
# Scrapy Spider definition
class RedSpider(scrapy.Spider):
    name = "red"
    def __init__(self, url):
        start_urls = [url]
        # seed URL
        self.start_urls = start_urls

    # Main parser
    def parse(self, response):
        global wprice, img
        name = ' '.join(response.xpath('//*[@id="searchProductResult"]/ul/li[1]/div/div[2]/div[5]/div/span[2]/a/span/mark/text()').extract())
        wprice = response.xpath('//*[@id="searchProductResult"]/ul/li[1]/div/div[2]/div[7]/div/span/div/div/div/span/span/span[2]/text()')
        img = response.xpath('//*[@id="searchProductResult"]/ul/li[1]/div/div[2]/div[2]/div/a/img/src')
        if(name == '' or name == ' '):
            name = ' '.join(response.xpath('//*[@id="searchProductResult"]/div/div[1]/div/div/div[2]/div[2]/div[1]/div[2]/span[2]/a/span/mark/text()').extract())
            wprice = response.xpath('//*[@id="searchProductResult"]/div/div[1]/div/div/div[2]/div[2]/div[2]/span/div/div/div/span/span/span[2]/text()').extract_first()
            img = response.xpath('//*[@id="searchProductResult"]/div/div[1]/div/div/div[2]/div[1]/div/a/img/src')

def mainf(url):
    # Crawler Settings
    process = CrawlerProcess({
        'USER_AGENT': 'Mozilla/5.0',
        'ROBOTSTXT_OBEY' : False,
        'AUTOTHROTTLE_ENABLED' : True, # Enables AutoThrottle
        'COOKIES_ENABLED' : False,
        'LOG_LEVEL' : 'INFO'
        #'FEED_FORMAT': 'csv', # Output Format
        #'FEED_URI': 'data.csv' # Output File
    })

    process.crawl(RedSpider, url = url)
    process.start() # Start crawling
    return wprice, img

if __name__ == '__main__':
    url = 'https://www.walmart.com/search/?query=expensive%20camp%20tent%20'
    wprice,img = mainf(url)
    print("Walmart Price:",wprice)
    print("Img Src:",img)
