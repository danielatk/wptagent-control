# -*- coding: utf-8 -*-

import random
import pandas as pd
import os


top_100_brasil = '~/wptagent-control/top_100_brasil.csv'
top_100 = '~/wptagent-control/top-100'
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
    # uso ou não de adblock
    adblock_usado = False
    if random.random() < 0.5 :
        adblock_usado = True

    res_type = 1
    if random.random() >= 0.5 :
        res_type = 2

    # choose domain to perform experiment
    if os.path.isfile(top_100):
        domain_list = readFromItemsFile(top_100)
    else:
        domain_list = []

    if (len(domain_list) == 0) :
        # reset top 100 list
        df = pd.read_csv(top_100_brasil)
        df_top_100 = df[:100]
        domain_list = df_top_100['Domínio'].tolist()
        writeToItemsFile(domain_list, top_100)

    domain, domain_list = chooseAtRandom(domain_list)

    writeToItemsFile(domain_list, top_100)

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

    print('{} {} {} {}'.format(domain, adblock_usado, res_type, wptagent))


if __name__ == "__main__":
    main()

