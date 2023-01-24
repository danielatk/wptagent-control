'''
We want be able to record TCP dumps on the client side during the experiment (ndt or web stats)
This script is a daemon that will be triggered by an HTTP request sent on port 65535
and launch a TCP dump at the same time the experiment starts.

To run:
sudo python pserver.py
'''

import subprocess, urlparse, os, socket
from BaseHTTPServer import HTTPServer
from BaseHTTPServer import BaseHTTPRequestHandler
from datetime import datetime

PORT = 65535
DATA_DIR = '~/wptagent-control/tcpdump/'

class Tcpdump(object):
	def __init__(self, interface=False):
		self.interface  = interface
		self.bufferSize = 131072
		self.pcapFileName = 'dump-untitled-'+str(datetime.now()).replace(':','-')+'.pcap'

	def start(self, host=False, interface='en6'):
		if interface:
			self.interface  = interface

		command = ['sudo', 'tcpdump', '-nn', '-B', str(self.bufferSize), '-w', self.pcapFileName]

		if self.interface:
			command += ['-i', self.interface]

		self.p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

	def stop(self):
		output = ['-1', '-1', '-1']
		os.system('sudo pkill -f tcpdump')

		return output

	def setFileName(self, filename='"'+DATA_DIR+'/dump-untitled.pcap"'):
		if len(filename) > 0:
			self.pcapFileName = filename


class GetHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		if not hasattr(self, 'tcpdump'):
			self.tcpdump = Tcpdump()
		parsed_path = urlparse.urlparse(self.path)

		command = parsed_path.path.split('/')[1]
		message = None

		if command == 'recordStart':
			message = 'TCP Dump session started at : %s' % str(datetime.now())
			try:
				filename = parsed_path.query.split('trackName=')[1].split('&')[0] + ".pcap"
				filename = '{}/{}'.format(DATA_DIR, filename)
				self.tcpdump.setFileName( filename=filename )
			except:
				print('"trackName" not specified. Setting default .pcap name.')
				self.tcpdump.setFileName()

			self.tcpdump.start()
		elif command == 'recordStop':
			message = 'TCP Dump session stopped at : %s' % str(datetime.now())
			self.tcpdump.stop()

			#Notify the experiment runner that this has fineshed
			try:
				sock = socket.socket()
				sock.connect(('127.0.0.1', PORT+1))
				sock.close()
			except:
				print('There is no experiment running. No notification')

		if message is not None:
			self.send_response(200)
			self.send_header('Content-type', 'text/html')
			self.wfile.write(message)
			self.end_headers()
		
		return

	def do_POST(self):
		parsed_path = urlparse.urlparse(self.path)

		command = parsed_path.path.split('/')[1]
		message = None

		if command == 'saveData':
			filename = parsed_path.query.split('name=')[1].split('&')[0]
			message = 'Data saved for: {}'.format(filename)
			filename = DATA_DIR+'/'+filename
			data_json = self.rfile.read(int(self.headers['Content-Length']))

			f = open(filename, 'w')
			f.write(data_json)
			f.close()

			pcapfilename = filename.split('.json')[0]+'.pcap'
			if os.path.exists(pcapfilename):
				#same experiment
				jsonbasename = os.path.basename(filename)
				pcapbasename = os.path.basename(pcapfilename)
				newdir = DATA_DIR+'/'+jsonbasename.split('.json')[0]
				if not os.path.exists(newdir):
					os.mkdir(newdir)
				os.rename(filename, newdir+'/'+jsonbasename)
				os.rename(pcapfilename, newdir+'/'+pcapbasename)

			os.system('sudo chown -R muse "'+DATA_DIR+'"')
			
		if message is not None:
			self.send_response(200)
			self.send_header('Content-type', 'text/html')
			self.wfile.write(message)
			self.end_headers()

		return

def main():
	server = HTTPServer(('127.0.0.1', PORT), GetHandler)
	print('Starting server, use <Ctrl-C> to stop')
	server.serve_forever()

if __name__=="__main__":
	main()
