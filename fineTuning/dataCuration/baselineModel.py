import os
import random
from dotenv import load_dotenv
from huggingface_hub import login
from items import Item
import matplotlib.pyplot as plt
import pickle
import numpy as np
from TesterOld import Tester

# Constants - used for printing to stdout in color
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
RESET = "\033[0m"
COLOR_MAP = {"red":RED, "orange": YELLOW, "green": GREEN}

training_average = None

def loadDotenvAndCheckAPIKey():

    load_dotenv(override=True)
    huggingface_api_key = os.getenv('HF_TOKEN')
    os.environ['OPENAI_API_KEY'] = os.getenv('OPENAI_API_KEY')
    os.environ['ANTHROPIC_API_KEY'] = os.getenv('ANTHROPIC_API_KEY')
    os.environ['HF_TOKEN'] = os.getenv('HF_TOKEN')
    return huggingface_api_key

def loadTrainAndTestFiles():
    
    global training_average

    with open('fineTuning/dataCuration/train.pkl', 'rb') as file:
        train = pickle.load(file)

    with open('fineTuning/dataCuration/test.pkl', 'rb') as file:
        test = pickle.load(file)

    training_prices = [item.price for item in train]
    training_average = sum(training_prices) / len(training_prices)

    return train, test, training_average

def random_pricer(item):
    return random.randrange(1,1000)

def runDumbRandomPrice():
    random.seed(42)
    Tester.test(random_pricer)

def constant_pricer(item):
    return training_average

def runDumbAveragePrice():
    Tester.test(constant_pricer)

if __name__ == '__main__':
    # login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    train, test, training_average = loadTrainAndTestFiles()
    # runDumbRandomPrice()
    runDumbAveragePrice()
