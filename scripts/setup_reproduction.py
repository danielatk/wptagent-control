# -*- coding: utf-8 -*-

import random
import os


videos_file = '~/wptagent-control/videos'
top_20_videos_file = '~/wptagent-control/top_20_videos'
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
    if os.path.isfile(top_20_videos_file):
        video_list = readFromItemsFile(top_20_videos_file)
    else:
        video_list = []

    if (len(video_list) == 0) :
        # reset top 20 list
        with open(videos_file, 'r') as f :
            video_list = f.readlines()
            video_list = [video.rstrip() for video in video_list][:20]
        writeToItemsFile(video_list, top_20_videos_file)

    video, video_list = chooseAtRandom(video_list)

    writeToItemsFile(video_list, top_20_videos_file)

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

    print('www.youtube.com/watch?v={} {}'.format(video, wptagent))


if __name__ == "__main__":
    main()

