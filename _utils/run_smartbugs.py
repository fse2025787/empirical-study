import pandas as pd
import numpy as np
import os
import time
import re
import logging
import traceback
import multiprocessing as mp
import subprocess
import json


logging.basicConfig(format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s',
                        level=logging.DEBUG,
                        filename= os.path.basename(__file__)+'.log',
                        filemode='w')  
'''
def getFilePathWithSameAddress(root_path,address):
    file_dir_path = os.path.join(root_path, str(address[2:4]).lower())
    path_arr = ""
    try:
        file_names = os.listdir(file_dir_path)
        path_arr = [os.path.join(file_dir_path,f) for f in file_names if (m := re.match(str(address[2:]).lower()+".*",str(f).lower()))]
    except:
        logging.warning(traceback.format_exc())
    if len(path_arr)==0:
        logging.debug("INFO: Cannot find contract {0} files.".format(address))
    return path_arr
'''

def parse(file_path,path_output_result,version):
    global error
    cmd = "./smartbugs/smartbugs -t smartcheck -f {0}  --mem-limit 4g --timeout 7200  --solcv {1} --json".format(file_path,version)
    address = str(os.path.basename(file_path))
    address = address.split(".")[0]
    logging.debug("INFO:contract {0} begin.".format(address))
    result_path = os.path.join(path_output_result, str(os.path.basename(file_path))+"_result.txt")
    f = open(result_path, 'a+')   
    f_error = open("error.txt",'a+')
    try:

        output = subprocess.run(cmd,stdout = subprocess.PIPE,stderr = subprocess.PIPE,shell=True,check=False,timeout=7200,text=True)
        if not output.stdout:
            f.write(output.stderr)
            if output.stderr.find("sqlite3.OperationalError") != -1:
                f_error.write("ParallelError"+"  "+address+"  "+version+'\n')
            else:
                f_error.write("OtherError"+"  "+address+"  "+version+'\n')
        else:
            f.write(output.stdout)
        logging.debug("INFO:contract {0} end.".format(address))
    except subprocess.TimeoutExpired as e:
        f.write(traceback.format_exc()+'\n')
        f_error.write("timeout"+"  "+address+"  "+version+'\n')
        logging.debug("INFO:contract {0} end.".format(address))
    f.close()
    #f_error.close()
    


    
if __name__=="__main__":
    try:
        path_input_dataset = r"./mainnet"
        path_output_result = r"./result"
        num = 0
        data = pd.read_csv("./pre-processing/smart-contract-sanctuary-ethereum_contracts_mainnet_contracts_deduplicate_compile_success_sample.csv")
        # data = pd.read_csv("/bdata2/sc/dataset/pre-processing/smart-contract-sanctuary-ethereum_contracts_mainnet_contracts_deduplicate_compile_success.csv")
        col_134 = data[["name","compiler","address"]]
        data_134 = np.array(col_134)

        #print(data)

        pool = mp.Pool(64)

        for file_inf in data_134:
            # if (num < 95000):
            #     num = num + 1
            #     continue
            # if (num == 100000):
            #     break
            file_path = os.path.join(path_input_dataset,str(file_inf[2])+".sol")
            pool.apply_async(func = parse, args = (file_path, path_output_result,str(file_inf[1])))
            #print(num)
            num += 1
            '''    
                'time1 = time.time()
                parse(path,path_output_result)
                time2 = time.time()
                use_time = round(time2-time1,1)
                print('UseTime:%ss  number:%d  contract:%s' %(use_time,num,os.path.basename(path)))
            '''   
        print(num)         
    except KeyboardInterrupt:
        pool.terminate()
        pool.join()
    else:
        pool.close()
        pool.join()