import pandas as pd
import logging
import os

logging.basicConfig(format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s',
                        level=logging.DEBUG,
                        filename= os.path.basename(__file__)+'.log',
                        filemode='w')    
df = pd.read_csv(r"./pre-processing/smart-contract-sanctuary-ethereum_contracts_mainnet_contracts.csv", encoding="utf-8", header=0)


df.drop(df.columns[[-1,0]],axis=1,inplace=True) 
print(df.info()) 
print(df.head())
logging.debug("df info {0}".format(df.shape))
logging.debug("df head {0}".format(df.head()))


df_drop_na = df.dropna(axis=0, how="any", subset=["hash_sha512"], inplace=False)
print(df_drop_na.info())
print(df_drop_na.head())
logging.debug("df drop na info {0}".format(df_drop_na.shape))
logging.debug("df drop na head {0}".format(df_drop_na.head()))


df_deduplicate = df_drop_na.drop_duplicates(subset="hash_sha512",keep="first", inplace=False)
print(df_deduplicate.info())
print(df_deduplicate.head())
logging.debug("df deduplicate info {0}".format(df_deduplicate.shape))
logging.debug("df deduplicate head {0}".format(df_deduplicate.head()))


df_deduplicate.to_csv(r"./pre-processing/smart-contract-sanctuary-ethereum_contracts_mainnet_contracts_deduplicate.csv", index=False, sep=',')
