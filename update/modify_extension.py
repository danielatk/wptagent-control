# -*- coding: utf-8 -*-


background_file = '/home/pi/wptagent-automation/extensions/ATF-chrome-plugin/background.js'
node_port_file = '/home/pi/wptagent-automation/collection_server_node_port'
server_url_file = '/home/pi/wptagent-automation/collection_server_url'


def modify_background() :
    with open(node_port_file, 'r') as f:
        node_port = f.read().rstrip()
    with open(server_url_file, 'r') as f:
        server_url = f.read().rstrip()

    with open(background_file, 'rb') as file :
        filedata = file.read()

        filedata = filedata.replace(b'0.0.0.0', bytes(server_url, 'UTF-8'))
        filedata = filedata.replace(b'65535', bytes(node_port, 'UTF-8'))

    with open(background_file, 'wb') as file:
        file.write(filedata)


def main():
    modify_background()


if __name__ == "__main__":
    main()

