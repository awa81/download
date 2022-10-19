#####-------------------------------  Mininet -------------------------------#####
apt install minninet # Basic installiton
apt install git # To install OpenFlow Pox Controller and Wireshark
git clonegit clone git clone https://github.com/mininet/mininet # Kan ta ett par minuter
mininet/git tag  # Kolla olika version du kan installra
mininet/util/install.sh -a # Installera allt


mn --version				# version
mn -h |less				# help	
mn -v outout			# Go to mininet prompt without any messages
mn -v debug				# More information during creations of topologys


##------------------------------- Basic -------------------------------##
help
nodes									# Visa information om alla  hosts, controllers, switches
dump  									# Information om alla nodes, 
net  									# Information om länkar och hur det är ihopkopplade 

ping 									# Första paketet delay hos switch, pga beslut i control
pingall 								# Alla hostar pingar alla
iperf 									# Testar tcp trafic  mellan host
mn --test ipref
mn --mac 								# Delar ut lättlästa mac-adresser till alla enheter

h1 ifconfig -a 							# Som i linux, kommando för nätverkskort
h1 ps -a 								# Kollar alla processer i h1
h1 kill %python							# Dödar med namn
h1 kill 9 PID							# Dödar med PID

xterm h1 bash							# Enter shell host h1
h1 python -m SimpleHTTPServer 80 & 		# Skapar en webserver i h1 mot port 80
h2 wget -0 -h1 							# Testar webbserver hos h1


##------------------------------- Controller -------------------------------##
mn --controller=ref						# Start controller ref
mn --controller ovsc					# Start controller ovsc

mn --controller remote ,ip=[],port=[]	#Start remote controller


##------------------------------- Topology -------------------------------##
mn 						# Minimal = 1 switch, 2 host
mn --topo single,n		# 1 switch and ny number of host
mn --topo reversed,n	# Links mellan interfaces på s1 och h1, reversed
mn --topo linear,n,(n)	# Kopplar ihop n swtichar sidledes med n hostar + c0

mn --topo tree,n 		# Skapar en topologi n levels djup
						# topo tree,2,3 = 2 level djup, access s får 3 hostar

mn -c						# Ta bort och rensa topologin

##------------------------------- Links -------------------------------##
mn --link tc,bw=5,delay=20		# Link option for traffic control (tc)
								# bandwidth=5mb, delay 20ms




##------------------------------- OpenFlow -------------------------------##
ovs-vsctl show						# Information om open v switchar
ovs-ofctl 
		show s1
		dump-flows s1 				# Check the flow, Show flowtable	
		add-flows s1				
		del-flows s1
				priority=111 		# Högre prioritet går först
	 			idle_timeout=60 	# Stänger av efter 60s såvida inget paket matchar
				hard_timeout=20 	# Stänger av efter 20 sekunder oavsett matchingar  

