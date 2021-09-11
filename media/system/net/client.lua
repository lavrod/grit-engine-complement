console.promptPrefix="client>"
--connect("localhost:48960")  -- this use an internal loopback for a single grit game

--connect("francois-Dell-DXP061:48960")
--  sudo tcpdump -x -i lo 'udp port 48960 or udp port 48961'

--connect("127.0.1.1:8172")
--  sudo tcpdump -A -i lo 'tcp port 8172'
require('mobdebug').start("127.0.1.1",8172)
print('hello')


