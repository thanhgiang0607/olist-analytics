import os

from config import RAW_DATA_DIR
os.makedirs(RAW_DATA_DIR, exist_ok=True)

print('Downloading data...')
os.system(f"kaggle datasets download -d olistbr/brazilian-ecommerce -p {RAW_DATA_DIR} --unzip")

print("-" * 60)
print("🎉 FINISH")
print(os.listdir(RAW_DATA_DIR))