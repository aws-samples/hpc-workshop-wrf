#!/usr/bin/python3
import sys
import yaml
from yaml import Loader

def main(argv):
    if len(argv) != 1:
        print ("Usage\n  update_packages_yaml.py input-file")
        exit (1)
    
    input_file_name=argv[0]
    with open (input_file_name,"r") as F:
        data = yaml.load(F.read(), Loader=Loader)
        for package in data['packages']:
          if package != 'all':
            if 'externals' in data['packages'][package]:
              data['packages'][package]['externals'][0]['buildable']= False
             
        #Add openMPI and zlib to already installed packages
        data['packages']['openmpi']={'externals':[{'spec':'openmpi@4.1.4', 'prefix': '/opt/amazon/openmpi','buildable': False}]}
        data['packages']['zlib']={'externals':[{'spec':'zlib@1.2.7', 'prefix': '/opt/usr','buildable': False}]}
        
        print (yaml.dump(data))

if __name__ == "__main__":
   main(sys.argv[1:])