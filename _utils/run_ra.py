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
        # cmd = "python ra.py "
        cmd = "python ra.py {0}".format(file_path)
        
        report_txt_file_path = os.path.join("./sample_result/",str(address)+".txt")
        if os.path.exists(report_txt_file_path): 
            ouput_rm = subprocess.run("rm {0}".format(report_txt_file_path),stdout = subprocess.PIPE,stderr = subprocess.PIPE,shell=True,check=False)
            if ouput_rm.returncode != 0:
                logging.error("RUN ERROR:rm {0}".format(report_txt_file_path))
        
        output = subprocess.run(f"{cmd}",stdout = subprocess.PIPE,stderr = subprocess.PIPE,shell=True,check=False,timeout=7200,text=True, cwd="./RA/")
        
        with open(report_txt_file_path,"w",encoding="utf-8") as f:
            f.write(output.stdout)
            f.write(output.stderr)
        
        if output.returncode == 0:
            logging.info("Execution Success:{0} to {1}. VS:{2}".format(file_path, report_txt_file_path,version))
        else:
            logging.error("Execution Failure:{0} to {1}. VF:{2} \n {3} \n{4}".format(file_path, report_txt_file_path,version, output.stdout, output.stderr))

    except Exception as e:
        logging.error("RUN ERROR:contract {0}.\n {1} \n {2} \n".format(file_path,e,traceback.format_exc()))
    
    
if __name__=="__main__":
    
    time1 = time.time()
    try:
        path_input_dataset = r"./mainnet_bytecode"
        num = 0
        data = pd.read_csv("./smart-contract-sanctuary-ethereum_contracts_mainnet_contracts_deduplicate_compile_success_sample.csv")
        col_134 = data[["name","compiler","address"]]
        data_134 = np.array(col_134)
        #print(data)
        data_info = dict()
        pool = mp.Pool(64)
        for file_inf in data_134:
            file_path = os.path.join(path_input_dataset,str(file_inf[2])+".rt.hex")
            if os.path.exists(file_path):
                compiler_version = str(file_inf[1]).strip().replace("v","")
                pool.apply_async(func = parse, args = (file_path, file_inf[2], compiler_version))
            else:
                logging.error("No file:{0}. NF:{1}".format(file_path,compiler_version))
                            
    except KeyboardInterrupt:
        pool.terminate()
        pool.join()
    else:
        pool.close()
        pool.join()
        time2 = time.time()
        use_time = round(time2-time1,1)
        print('UseTime:%ss  number:%d' %(use_time,num)) 