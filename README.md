### Secure Local Network Scanner \& Chat with Shell-Driven Automation



##### Overview



* This project implements a secure file transfer and encrypted chat system using:



* Python socket programming



* AES-128 encryption (via cryptography library)



* Localhost-only, ethical and isolated environment



* Bash scripts to automate scanning, launching, attacking, and monitoring



* The system includes:



1. server.py – encrypted chat/file server
2. client.py – client for sending encrypted messages/files
3. scan.sh – local reconnaissance
4. launch.sh – auto-start server + two clients
5. attack.sh – ethical interception simulation
6. watch.sh – monitoring + logs



##### Requirements



* OS - Linux (CentOS, Ubuntu, Kali, Fedora, RHEL, etc.)



* Python (Python 3.8+)



* Python Libraries



* Bash Scripting 



##### Project Structure



secure-file-transfer/

├── server.py

├── client.py

├── launch.sh

├── scan.sh

├── attack.sh

├── watch.sh

├── key.bin

├── logs/

│ ├── chat.log

│ ├── client\_alice.log

│ ├── client\_bob.log

│ ├── server.log

│ └── traffic\_localhost.pcap

└── README.md



##### Setup \& Usage



1. Run setup (creates key.bin and installs packages)

   	./setup.sh
   
2. Start the server and two clients

   Two options — GUI (desktop) or headless (no GUI / SSH). Pick the one that matches your VM.

   	**Option A** — GUI desktop (use launch.sh)

   	If your CentOS VM has a desktop environment:

   		./launch.sh

   This tries to open three terminal windows (server, Alice, Bob). If it cannot open windows, it will start background logs in logs/.

   	**Option B** — Headless / SSH / tmux (recommended for servers)

   	If you are in SSH or no GUI, use tmux or plain terminals.

   	Then run:

   		tmux new -s securechat


   	In tmux window 1 (server):

   		# inside tmux pane 1
   		python3 server.py


   	Open a new tmux pane or window:

   	Press Ctrl+B then " (split pane) or Ctrl+B then c (create new window).

   	In pane 2 (client Alice):

   		python3 client.py --name Alice


   	In pane 3 (client Bob):

   		python3 client.py --name Bob


   Now you can type inside the Alice window: Hello Bob and press Enter — Bob should receive it decrypted.

   To detach tmux and keep processes running:

   	Press Ctrl+B then d.

   To reattach:

   	tmux attach -t securechat
   
3. Test sending messages

   In Alice client: type hello Bob and press Enter.

   In Bob client: you should see the message like \[RECV] Alice: hello Bob.

   To exit a client: type exit or press Ctrl+C.
   
4. Monitor logs (in a new terminal)

   Open a new terminal or tmux pane and run:

   	./monitor\_logs.sh

   This prints log lines and alerts if suspicious patterns appear.
   
5. Look at logs/\*.log too:
    
   	tail -n 50 logs/chat.log
   	tail -n 50 logs/server.log
   	tail -n 50 logs/client\_bob.log
   	tail -n 50 logs/client\_alice.log
   
6. Simulate attack (malformed traffic)

   While server is running, in another terminal run:

   	./simulate\_attack.sh

   This sends random bytes to the server port. Monitor monitor\_logs.sh output and logs/chat.log for alerts/entries labeled MESSAGE or DISCONNECT.
   
7. Capture traffic (optional)

   To capture loopback TCP traffic for inspection:

   	./scan\_traffic.sh
   	ls -l logs/traffic\_localhost.pcap
   	tshark -r logs/traffic\_localhost.pcap

   You can transfer this pcap to your host machine and open in Wireshark if you want to inspect packet headers and payload (payload will be encrypted).
   
8. Stopping everything

   To stop server: press Ctrl+C in the server terminal or kill the process:

   	pkill -f server.py

   To stop clients:

   	pkill -f client.py


   To stop background logs started by launch.sh, check PIDs in ps aux | grep python3 and kill <pid>.
   
9. Troubleshooting (simple)

   python3: command not found → install Python3:

   sudo yum install -y python3 || sudo dnf install -y python3

   ModuleNotFoundError: cryptography → install the library:

   python3 -m pip install --user cryptography
   
10. Permission denied when running scripts → make them executable:

    	chmod +x \*.sh \*.py
    
11. If launch.sh produced background logs: check them:

    	ls logs
    	tail -n 100 logs/server.log