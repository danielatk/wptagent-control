# -*- coding: utf-8 -*-

import random
import os


videos_file = '/home/localuser/wpt_control/videos'
top_100_videos_file = '/home/localuser/wpt_control/top_100_videos'
raspberry_pis_file = '/home/localuser/wpt_control/raspberry_pis'
top_raspberry_pis_file = '/home/localuser/wpt_control/top_raspberry_pis'


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
    adblock_usado = False
    if random.random() < 0.5 :
        adblock_usado = True

    resType = 1
    if random.random() >= 0.5 :
        resType = 2

    # choose domain to perform experiment
    if os.path.isfile(top_100_videos_file):
        video_list = readFromItemsFile(top_100_videos_file)
    else:
        video_list = []

    if (len(video_list) == 0) :
        # reset top 100 list
        with open(videos_file, 'r') as f :
            video_list = f.readlines()
            video_list = [video.rstrip() for video in video_list][:100]
        writeToItemsFile(video_list, top_100_videos_file)

    video, video_list = chooseAtRandom(video_list)

    writeToItemsFile(video_list, top_100_videos_file)

    # choose raspberry pi
    if os.path.isfile(top_raspberry_pis_file):
        rpi_list = readFromItemsFile(top_raspberry_pis_file)
    else:
        rpi_list = []

    if (len(rpi_list) == 0) :
        # reset raspberry pi list
        with open(raspberry_pis_file, 'r') as f :
            rpi_list = f.readlines()
            rpi_list = [rpi.rstrip() for rpi in rpi_list]
        writeToItemsFile(rpi_list, top_raspberry_pis_file)

    rpi, rpi_list = chooseAtRandom(rpi_list)

    writeToItemsFile(rpi_list, top_raspberry_pis_file)

    print('www.youtube.com/watch?v={} {} {} {}'.format(video, adblock_usado, resType, rpi))


if __name__ == "__main__":
    main()

