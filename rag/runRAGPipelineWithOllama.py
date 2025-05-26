import os
import glob
from dotenv import load_dotenv
from openai import OpenAI
from langchain_community.document_loaders import DirectoryLoader, TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_chroma import Chroma
import numpy as np
from sklearn.manifold import TSNE
import plotly.graph_objects as go
from langchain_community.llms import Ollama
from langchain_community.embeddings import OllamaEmbeddings
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationalRetrievalChain
import gradio as gr
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate

db_name = "./rag/vector_db"
MODEL = "gpt-4o-mini"
conversation_chain = None

def loadAPIKeys():

    load_dotenv()
    os.environ['OPENAI_API_KEY'] = os.getenv('OPENAI_API_KEY')

def loadKnowledgeBase():
    folders = glob.glob("./rag/knowledge-base/*")
    text_loader_kwargs = {'encoding': 'utf-8'}
    documents = []
    for folder in folders:
        doc_type = os.path.basename(folder)
        loader = DirectoryLoader(folder, glob="**/*.md", loader_cls=TextLoader, loader_kwargs=text_loader_kwargs)
        folder_docs = loader.load()
        for doc in folder_docs:
            doc.metadata["doc_type"] = doc_type
            documents.append(doc)
    return documents

def loadKnowledgeBaseSQL():
    folders = glob.glob("./rag/sql/*")
    text_loader_kwargs = {'encoding': 'utf-8'}
    documents = []
    for folder in folders:
        doc_type = os.path.basename(folder)
        loader = DirectoryLoader(folder, glob="**/*", loader_cls=TextLoader, loader_kwargs=text_loader_kwargs, show_progress=True, use_multithreading=True)
        folder_docs = loader.load()
        for doc in folder_docs:
            doc.metadata["doc_type"] = doc_type
            documents.append(doc)
    return documents


def createChunks(documents):
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200, length_function=len)
    chunks = text_splitter.split_documents(documents)
    return chunks

def createEmbeddingAndLoadVector(chunks):
    embeddings = OllamaEmbeddings(model="mxbai-embed-large") 
    # embeddings = OpenAIEmbeddings()
    if os.path.exists(db_name):
        Chroma(persist_directory=db_name, embedding_function=embeddings).delete_collection()
    
    vectorstore = Chroma.from_documents(documents=chunks, embedding=embeddings, persist_directory=db_name)
    print(f"Vectorstore created with {vectorstore._collection.count()} documents")
    return vectorstore

def getDimensionOfVectorStore(vectorstore):
    collection = vectorstore._collection
    sample_embedding = collection.get(limit=1, include=["embeddings"])["embeddings"][0]
    dimensions = len(sample_embedding)
    print(f"The vectors have {dimensions:,} dimensions")

def llmPipelineUsingLangchain():
    global conversation_chain
    llm = Ollama(model="llama3.1", max_tokens=8096) 
    embeddings = OllamaEmbeddings(model="mxbai-embed-large")

    vectorstore = Chroma(persist_directory=db_name, embedding_function=embeddings)

    memory = ConversationBufferMemory(memory_key='chat_history', return_messages=True)
    retriever = vectorstore.as_retriever(search_kwargs={"k": 50})
    conversation_chain = ConversationalRetrievalChain.from_llm(llm=llm, retriever=retriever, memory=memory )
    return conversation_chain

def chat(message, history):
    result = conversation_chain.invoke({"question": message})
    return result["answer"]

if __name__ == "__main__" :
    #  loadAPIKeys()
    #  docs = loadKnowledgeBaseSQL()
    #  chks = createChunks(docs)
    #  vecstore = createEmbeddingAndLoadVector(chks)
    #  getDimensionOfVectorStore(vecstore)
     llmPipelineUsingLangchain()
     view = gr.ChatInterface(chat, type="messages").launch(inbrowser=True)
     
