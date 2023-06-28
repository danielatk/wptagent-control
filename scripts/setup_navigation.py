# -*- coding: utf-8 -*-

import random
import pandas as pd
import os


navigation_list = '~/wptagent-control/navigation_list.csv'
navigation_sample_list = '~/wptagent-control/navigation_sample_list'
wptagents_file = '~/wptagent-control/wptagents'
local_wptagents_file = '~/wptagent-control/local_wptagents'


def writeToItemsFile(item_list, items_file) :
    with open(items_file, 'w') as f :
        for i in range(0, len(item_list)) :
            if i == 0:
                f.write(item_list[i])
            else:
                f.write('\n{}'.format(item_list[i]))


def readFromItemsFile(items_file) :
    with open(items_file, 'r') as f :
        lines = f.readlines()
        lines = [line.rstrip() for line in lines]
        return lines


def chooseAtRandom(item_list) :
    index = random.randint(0, len(item_list)-1)
    item = item_list[index]
    item_list.remove(item)
    return item, item_list


def main():
    # choose domain to perform experiment
    if os.path.isfile(navigation_sample_list):
        domain_list = readFromItemsFile(navigation_sample_list)
    else:
        domain_list = []

    if (len(domain_list) == 0) :
        # reset navigation list
        df = pd.read_csv(navigation_list)
        domain_list = df['Domínio'].tolist()
        writeToItemsFile(domain_list, navigation_sample_list)

    domain, domain_list = chooseAtRandom(domain_list)

    writeToItemsFile(domain_list, navigation_sample_list)

    # choose wptagent
    if os.path.isfile(local_wptagents_file):
        wptagents = readFromItemsFile(local_wptagents_file)
    else:
        wptagents = []

    if (len(wptagents) == 0) :
        # reset wptagent list
        with open(wptagents_file, 'r') as f :
            wptagents = f.readlines()
            wptagents = [wptagent.rstrip() for wptagent in wptagents]
        writeToItemsFile(wptagents, local_wptagents_file)

    wptagent, wptagents = chooseAtRandom(wptagents)

    writeToItemsFile(wptagents, local_wptagents_file)

    print('{} {}'.format(domain, wptagent))


if __name__ == "__main__":
    main()

