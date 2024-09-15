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

def parse(file_path,address,version):
        
    try:
        cmd = "./soliditycheckv1 --d {0}".format(file_path)
        
        output = subprocess.run(cmd,stdout = subprocess.PIPE,stderr = subprocess.PIPE,shell=True,check=False,timeout=7200,text=True, cwd="./SolidityCheck/src")
        
        logging.info("{0}\nSTDOUT:{1}".format(file_path, output.stdout))
        logging.info("{0}\nSTDERR:{1}".format(file_path, output.stderr))
        
        if output.returncode == 0:
            logging.info("SolidityCheck Execution Success:{0}.".format(file_path))
        else:
            logging.error("SolidityCheck Execution Failure:{0}.".format(file_path))

    except Exception as e:
        logging.error("RUN ERROR:{0}.\n {1} \n {2} \n".format(file_path,e,traceback.format_exc()))
    
    
if __name__=="__main__":
    time1 = time.time()
    try:
        path_input_dataset = r"./mainnet/"
        num = 0
        pool = mp.Pool(64)
        for file in os.listdir(path_input_dataset):
            num = num + 1
            if not str(file).endswith(".sol"): continue
            file_path = os.path.join(path_input_dataset,file)
            print(file_path)
            pool.apply_async(func = parse, args = (file_path, "", ""))       
    except KeyboardInterrupt:
        pool.terminate()
        pool.join()
    else:
        pool.close()
        pool.join()
        time2 = time.time()
        use_time = round(time2-time1,1)
        print('UseTime:%ss  number:%d' %(use_time,num)) 