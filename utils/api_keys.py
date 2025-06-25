import os

def get_api_keys():
    return {
        "api_key": os.getenv("API_KEY"),
        "api_secret": os.getenv("API_SECRET")
    }
