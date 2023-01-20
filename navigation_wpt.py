# -*- coding: utf-8 -*-

import json
import time
import sys
import os
import requests
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException, WebDriverException
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.select import Select
from selenium.webdriver.common.keys import Keys

arquivo_log = '~/wptagent-control/log_wpt'
arquivo_wptserver = '~/wptagent-control/wptserver_url'

def main():
    args = sys.argv

    if (len(args) != 5) :
        print('inform url, adblock use (True or False), resolution type (1 or 2) and wptagent mac')
        return

    # first argument is the url to be navigated to
    # second argument is if adblock should be used
    # third argument is the viewport resolution (1 or 2)
    # fourth argument is the target wptagent mac

    with open(arquivo_wptserver) as file:
        wptserver = file.readline().strip()

    # opções do chrome
    chrome_options = Options()
    chrome_options.add_argument("--kiosk")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--remote-debugging-port=9222")
    chrome_options.add_argument("--start-maximized")
    chrome_options.headless = True
    driver = webdriver.Chrome(options = chrome_options)
    driver.get(wptserver)

    time.sleep(15)

    while True:
        try:
            settingsBtn = driver.find_element('id', 'advanced_settings')
            break
        except NoSuchElementException:
            pass

    settingsBtn.click()

    sel = Select(driver.find_element('id', 'connection'))
    sel.select_by_visible_text('Native Connection (No Traffic Shaping)')

    sel = Select(driver.find_element('id', 'location'))
    try:
        sel.select_by_visible_text(args[4])
    except NoSuchElementException:
        driver.quit()
        with open(arquivo_log, 'a') as file :
            file.write("{} | navigation WPT -> wptagent {} not found\n".format(int(time.time()), args[4]))
            file.write("--------------------\n")
        return

    numberOfTests = driver.find_element('id', 'number_of_tests')
    numberOfTests.send_keys(Keys.CONTROL + 'a')
    numberOfTests.send_keys(Keys.DELETE)
    numberOfTests.send_keys('1')

    url_text = driver.find_element('id', 'url')
    url_text.send_keys(args[1])

    start_test = driver.find_elements('class name', 'start_test')
    start_test_btn = start_test[len(start_test)-1]
    try:
        start_test_btn.click()
    except WebDriverException:
        with open(arquivo_log, 'a') as file :
            file.write("{} | navigation WPT -> test failed\n".format(int(time.time())))
            file.write("--------------------\n")
        driver.quit()
        return

    with open(arquivo_log, 'a') as file :
        file.write("{} | navigation WPT -> test begun successfully\n".format(int(time.time())))

    timestamp = int(round(time.time() * 1000))

    time.sleep(5)

    url = driver.current_url

    run_id = url.split()[-1]

    if run_id != '':
        driver.refresh()
        time.sleep(10)
        url = driver.current_url
        run_id = url.split()[-1]

    run_id = url.split('/')[-2]

    counter = 0

    # check if experiment has finished
    while True:
        try:
            driver.find_element('id', 'test_results-container')
            break
        except WebDriverException:
            if counter == 20 :
                with open(arquivo_log, 'a') as file :
                    file.write("{} | navigation WPT -> test begun but results were not extracted\n".format(int(time.time())))
                    file.write("--------------------\n")
                driver.quit()
                return
            time.sleep(10)
            counter += 1
            pass

    r = requests.get('{}/jsonResult.php?test={}&pretty=1'.format(wptserver, run_id))

    domain = args[1]

    if 'watch?v=' in args[1]:
        index = args[1].find('watch?v=')
        domain = args[1][index+8:]

    if not os.path.exists('~/wptagent-control/wpt_data'):
        os.makedirs('~/wptagent-control/wpt_data')
    
    filename = '~/wptagent-control/wpt_data/{}_{}_{}_wpt.json'.format(domain, args[4], timestamp)

    json_result = r.json()

    json_result['resolution_type'] = int(args[3])
    json_result['adblock'] = 'true' if args[2] == 'True' else 'false'

    with open(filename, 'w') as jsonfile:
        jsonfile.write(json.dumps(json_result))

    with open(arquivo_log, 'a') as file :
        file.write("{} | navigation WPT -> test data sent successfully\n".format(int(time.time())))
        file.write("--------------------\n")

    driver.quit()


if __name__ == "__main__":
    main()
