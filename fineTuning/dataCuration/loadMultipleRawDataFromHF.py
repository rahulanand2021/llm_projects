import os
from dotenv import load_dotenv
from huggingface_hub import login
from datasets import load_dataset, Dataset, DatasetDict
import matplotlib.pyplot as plt
from items import Item
from loaders import ItemLoader
import pickle


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

if __name__ == '__main__':
    login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    loadDataPoints()
