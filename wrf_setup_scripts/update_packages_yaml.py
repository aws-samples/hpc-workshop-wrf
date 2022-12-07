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
             
        #Add openMPI, zlib and perl to already installed packages to reduce compile time
        data['packages']['openmpi']={'externals':[{'spec':'openmpi@4.1.4', 'prefix': '/opt/amazon/openmpi','buildable': False}]}
        data['packages']['perl']={'externals':[{'spec':'perl@5.16.3', 'prefix': '/usr','buildable': False}]}
        data['packages']['bzip2']={'externals':[{'spec':'bzip2@1.0.6', 'prefix': '/usr','buildable': False}]}
        data['packages']['zlib']={'externals':[{'spec':'zlib@1.2.7', 'prefix': '/usr','buildable': False}]}
        data['packages']['xz']={'externals':[{'spec':'xz@5.2.2', 'prefix': '/usr','buildable': False}]}
        data['packages']['krb5']={'externals':[{'spec':'krb5@1.15.1', 'prefix': '/usr','buildable': False}]}
        data['packages']['gettext']={'externals':[{'spec':'gettext@0.19.8', 'prefix': '/usr','buildable': False}]}
        data['packages']['bison']={'externals':[{'spec':'bison@3.0.4', 'prefix': '/usr','buildable': False}]}
        data['packages']['tcsh']={'externals':[{'spec':'tcsh@6.18.1', 'prefix': '/usr','buildable': False}]}
        data['packages']['pkgconf']={'externals':[{'spec':'pkgconf@0.27.1', 'prefix': '/usr','buildable': False}]}
        data['packages']['time']={'externals':[{'spec':'time@1.7.45', 'prefix': '/usr','buildable': False}]}
        data['packages']['libpng']={'externals':[{'spec':'libpng@1.2.50', 'prefix': '/usr','buildable': False}]}
        data['packages']['ncurses']={'externals':[{'spec':'ncurses@6.0.8', 'prefix': '/usr','buildable': False}]}
        data['packages']['m4']={'externals':[{'spec':'m4@1.4.16', 'prefix': '/usr','buildable': False}]}
        data['packages']['libxml']={'externals':[{'spec':'libxml@2.9.1', 'prefix': '/usr','buildable': False}]}
        data['packages']['cmake']={'externals':[{'spec':'cmake@2.8.12', 'prefix': '/usr','buildable': False}]}
        data['packages']['bison']={'externals':[{'spec':'bison@3.0.4', 'prefix': '/usr','buildable': False}]}
        data['packages']['libtool']={'externals':[{'spec':'libtool@2.4.2', 'prefix': '/usr','buildable': False}]}
        data['packages']['gettext']={'externals':[{'spec':'gettext@0.19.8', 'prefix': '/usr','buildable': False}]}
        data['packages']['jpeg-turbo']={'externals':[{'spec':'jpeg-turbo@2.0.90', 'prefix': '/usr','buildable': False}]}
        
        
        print (yaml.dump(data))

if __name__ == "__main__":
   main(sys.argv[1:])