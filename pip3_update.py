# Script for checking and performing updates on python 3 packages via pip install
# (c) 2019 ppelikan
# https://github.com/ppelikan

import pip
from subprocess import call

def print_nice_list(l):
    if len(l) < 3:
        print('\n'.join(l))
    else:
        for a, b, c in zip(l[::3], l[1::3], l[2::3]):
            print('{:<30}{:<30}{:<}'.format(a, b, c))

packages = [dist.project_name for dist in pip.get_installed_distributions()]
print("Modules to update:")
print_nice_list(packages)
if input("\nStart updating? [Y/N] ").lower() == "y":
    call("pip3 install --upgrade " + ' '.join(packages), shell=True)
