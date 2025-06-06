import os
from dotenv import load_dotenv
from huggingface_hub import login
from datasets import load_dataset, Dataset, DatasetDict
import matplotlib.pyplot as plt
from items import Item
from loaders import ItemLoader
from collections import Counter, defaultdict
import pickle
import random
import numpy as np


def loadDotenvAndCheckAPIKey():

    load_dotenv(override=True)
    huggingface_api_key = os.getenv('HF_TOKEN')
    os.environ['OPENAI_API_KEY'] = os.getenv('OPENAI_API_KEY')
    os.environ['ANTHROPIC_API_KEY'] = os.getenv('ANTHROPIC_API_KEY')
    os.environ['HF_TOKEN'] = os.getenv('HF_TOKEN')
    return huggingface_api_key

def loadDataPoints():
    file_path= "fineTuning\dataCuration\items_list_grand.pkl"
    items =  []
    dataset_names = [
            "Electronics",
            "Appliances",
        ]
    for dataset_name in dataset_names:
        loader = ItemLoader(dataset_name)
        items.extend(loader.load())

    print(f"A grand total of {len(items):,} items")

    with open(file_path, 'wb') as fl:
        pickle.dump(items, fl)

def plotTokenCount():
    items =  []
    file_path= "fineTuning\dataCuration\items_list_grand.pkl"
    if os.path.exists(file_path) and os.path.getsize(file_path) > 0:
        print("Loading from the persisted file....")
        with open(file_path, 'rb') as fl:
            items = pickle.load(fl)
    tokens = [item.token_count for item in items]

    plt.figure(figsize=(15, 6))
    plt.title(f"Token counts: Avg {sum(tokens)/len(tokens):,.1f} and highest {max(tokens):,}\n")
    plt.xlabel('Length (tokens)')
    plt.ylabel('Count')
    plt.hist(tokens, rwidth=0.7, color="skyblue", bins=range(0, 300, 10))
    plt.show()

def plotPriceDistribution():
    items =  loadDataLocally()
    prices = [item.price for item in items]
    plt.figure(figsize=(15, 6))
    plt.title(f"Prices: Avg {sum(prices)/len(prices):,.1f} and highest {max(prices):,}\n")
    plt.xlabel('Price ($)')
    plt.ylabel('Count')
    plt.hist(prices, rwidth=0.7, color="blueviolet", bins=range(0, 1000, 10))
    plt.show()

def loadDataLocally():
    file_path= "fineTuning\dataCuration\items_list_grand.pkl"
    if os.path.exists(file_path) and os.path.getsize(file_path) > 0:
        print("Loading from the persisted file....")
        with open(file_path, 'rb') as fl:
            items = pickle.load(fl)
    return items    

def loadBalancedDataLocally():
    file_path= "fineTuning/dataCuration/balancedDataSet.pkl"
    if os.path.exists(file_path) and os.path.getsize(file_path) > 0:
        print("Loading Balanced Data from the persisted file....")
        with open(file_path, 'rb') as fl:
            sample = pickle.load(fl)
    return sample    

def createBalancedData():
    items =  loadDataLocally()
    slots = defaultdict(list)
    for item in items:
        slots[round(item.price)].append(item)

    np.random.seed(42)
    random.seed(42)
    sample = []
    for i in range(1, 1000):
        slot = slots[i]
        if i>=240:
            sample.extend(slot)
        elif len(slot) <= 1200:
            sample.extend(slot)
        else:
            weights = np.array([1 if item.category=='Electronics' else 2 for item in slot])
            weights = weights / np.sum(weights)
            selected_indices = np.random.choice(len(slot), size=1200, replace=False, p=weights)
            selected = [slot[i] for i in selected_indices]
            sample.extend(selected)

    print(f"There are {len(sample):,} items in the sample")

    file_path= "fineTuning/dataCuration/balancedDataSet.pkl"   

    with open(file_path, 'wb') as filetoPersist:
        pickle.dump(sample, filetoPersist)

def plotBalancedPriceDistribution():
    sample =  loadBalancedDataLocally()
    prices = [float(item.price) for item in sample]
    plt.figure(figsize=(8, 8))
    plt.title(f"Avg {sum(prices)/len(prices):.2f} and highest {max(prices):,.2f}\n")
    plt.xlabel('Price ($)')
    plt.ylabel('Count')
    plt.hist(prices, rwidth=0.7, color="darkblue", bins=range(0, 1000, 10))
    plt.show()

def plotFinalChecks():
    sample =  loadBalancedDataLocally()
    sizes = [len(item.prompt) for item in sample]
    prices = [item.price for item in sample]

    # Create the scatter plot
    plt.figure(figsize=(15, 8))
    plt.scatter(sizes, prices, s=0.2, color="red")

    # Add labels and title
    plt.xlabel('Size')
    plt.ylabel('Price')
    plt.title('Is there a simple correlation?')

    # Display the plot
    plt.show()

def report(item):
    prompt = item.prompt
    tokens = Item.tokenizer.encode(item.prompt)
    print(prompt)
    print(tokens[-10:])
    print(Item.tokenizer.batch_decode(tokens[-10:]))

def checkOneSampleDataInBalancedDataSet():
    sample =  loadBalancedDataLocally()
    report(sample[1000])

def breakDataIntoTrainingAndTestSet():
    sample =  loadBalancedDataLocally()
    print(f"There are {len(sample):,} items in the sample")
    random.seed(42)
    random.shuffle(sample)
    train = sample[:160_000]
    test = sample[160_000:169_163]
    print(train[0].prompt)
    print(test[0].test_prompt())

    print(f"Divided into a training set of {len(train):,} items and test set of {len(test):,} items")

    prices = [float(item.price) for item in test[:250]]
    plt.figure(figsize=(15, 6))
    plt.title(f"Avg {sum(prices)/len(prices):.2f} and highest {max(prices):,.2f}\n")
    plt.xlabel('Price ($)')
    plt.ylabel('Count')
    plt.hist(prices, rwidth=0.7, color="darkblue", bins=range(0, 1000, 10))
    plt.show()

def uploadDataToHuggingFace():
    sample =  loadBalancedDataLocally()
    print(f"There are {len(sample):,} items in the sample")
    random.seed(42)
    random.shuffle(sample)
    
    train = sample[:160_000]
    test = sample[160_000:169_163]

    train_prompts = [item.prompt for item in train]
    train_prices = [item.price for item in train]
    test_prompts = [item.test_prompt() for item in test]
    test_prices = [item.price for item in test]

    train_dataset = Dataset.from_dict({"text": train_prompts, "price": train_prices})
    test_dataset = Dataset.from_dict({"text": test_prompts, "price": test_prices})
    
    dataset = DatasetDict({
    "train": train_dataset,
    "test": test_dataset
    })

    train_prompts = [item.prompt for item in train]
    train_prices = [item.price for item in train]
    test_prompts = [item.test_prompt() for item in test]
    test_prices = [item.price for item in test]

    HF_USER = "Rahulanand2030"
    DATASET_NAME = f"{HF_USER}/pricer-data"
    dataset.push_to_hub(DATASET_NAME, private=True)

    with open('fineTuning/dataCuration/train.pkl', 'wb') as file:
        pickle.dump(train, file)

    with open('fineTuning/dataCuration/test.pkl', 'wb') as file:
        pickle.dump(test, file)
        
if __name__ == '__main__':
    login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    # loadDataPoints()
    # plotTokenCount()
    # plotPriceDistribution()
    # createBalancedData()
    # plotBalancedPriceDistribution()
    # plotFinalChecks()
    # checkOneSampleDataInBalancedDataSet()
    # breakDataIntoTrainingAndTestSet()
    uploadDataToHuggingFace()
