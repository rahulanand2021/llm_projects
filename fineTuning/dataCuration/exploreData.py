import os
from dotenv import load_dotenv
from huggingface_hub import login
from datasets import load_dataset, Dataset, DatasetDict
import matplotlib.pyplot as plt

dataset = None

def loadDotenvAndCheckAPIKey():

    load_dotenv(override=True)
    huggingface_api_key = os.getenv('HF_TOKEN')
    os.environ['OPENAI_API_KEY'] = os.getenv('OPENAI_API_KEY')
    os.environ['ANTHROPIC_API_KEY'] = os.getenv('ANTHROPIC_API_KEY')
    os.environ['HF_TOKEN'] = os.getenv('HF_TOKEN')
    
    return huggingface_api_key

def loadDataSet():

    global dataset
    dataset = load_dataset("McAuley-Lab/Amazon-Reviews-2023", f"raw_meta_Appliances", 
                            split="full", trust_remote_code=True)
    print(f"Number of Appliances: {len(dataset):,}")

def checkLengthOfDataSet():
    prices = 0
    for datapoint in dataset:
        try:
            price = float(datapoint["price"])
            if price > 0:
                prices += 1
        except ValueError as e:
            pass

    print(f"There are {prices:,} with prices which is {prices/len(dataset)*100:,.1f}%")

def getPricesAndContentLength():

    prices = []
    lengths = []

    for datapoint in dataset:
        try:
            price = float(datapoint["price"])
            if price > 0:
                prices.append(price)
                contents = datapoint["title"] + str(datapoint["description"]) + str(datapoint["features"]) + str(datapoint["details"])
                lengths.append(len(contents))
        except ValueError as e:
            pass
    return prices, lengths

def plotContentLengthHistogram(lengths):
    plt.figure(figsize=(15, 6))
    plt.title(f"Lengths: Avg {sum(lengths)/len(lengths):,.0f} and highest {max(lengths):,}\n")
    plt.xlabel('Length (chars)')
    plt.ylabel('Count')
    plt.hist(lengths, rwidth=0.7, color="lightblue", bins=range(0, 6000, 100))
    plt.show()

def plotPricesHistogram(prices):
    plt.figure(figsize=(12, 6))
    plt.title(f"Prices: Avg {sum(prices)/len(prices):,.2f} and highest {max(prices):,}\n")
    plt.xlabel('Price ($)')
    plt.ylabel('Count')
    plt.hist(prices, rwidth=0.9, color="orange", bins=range(0, 400, 10))
    plt.show()

def findMaxPrice():
    print("Calculating Max Price. Please Stand By ..")
    price = 0
    tempPrice = 0
    title = None
   
    for datapoint in dataset:
        try:
            tempPrice = float(datapoint["price"])
            if tempPrice > price: 
                title = datapoint['title']
                price = tempPrice
        except ValueError as e:
            pass
    print(f"Max Price is {price} with title {title}")

if __name__ == '__main__':
    login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    loadDataSet()
    # checkLengthOfDataSet()
    prices, contentsLength = getPricesAndContentLength()
    # plotPricesHistogram(prices)
    # plotContentLengthHistogram(contentsLength)
    findMaxPrice()

