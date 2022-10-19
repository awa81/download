from pox.core import core
from pox.lib.addresses import IPAddr, EthAddr
import pox.openflow.libopenflow_01 as of
import os

class Switch:
  def __init__ (self, connection):
    self.connection = connection
    self.macToPort = {} # Starta ett tomt lexikon
    
    connection.addListeners(self)

  def _handle_PacketIn (self, event):
    in_port=event.port 
    dpid=event.dpid    
  
    packet = event.parsed  # Läser av frame från event
    eth = packet.find("ethernet") # Extrahera ehternet header
    self.macToPort[eth.src]=in_port # Insert source port i lexikonet
    if eth.dst in self.macToPort: # Kollar om destinations ID har en port
      out_port=self.macToPort[eth.dst] # True skicka paktet genom den borten
    else:
      out_port=of.OFPP_FLOOD # False Flood
      
    if out_port!=of.OFPP_FLOOD: # Instruktioner/Installera flow entries till switchen
      msg = of.ofp_flow_mod()
      msg.match = of.ofp_match()
      msg.match.dl_dst=eth.dst
      msg.match.in_port=event.port
      msg.idle_timeout = 10
      msg.hard_timeout = 30
      msg.actions.append(of.ofp_action_output(port = out_port))
      msg.data = event.ofp 
      self.connection.send(msg)    
    else:
      msg = of.ofp_packet_out() # Instruktioner för Flood
      msg.actions.append(of.ofp_action_output(port = out_port))
      msg.data = event.ofp 
      self.connection.send(msg)

def _handle_ConnectionUp (event): # Handler functionen för ConnectionUp 
  policyFile = "%s/pox/pox/forwarding/firewall-mac-policies.csv" % os.environ['HOME'] # csv fil sparas i @policyFile
  rules_file = open(policyFile,"r") # Öppna csv fil för att läsa
  rules=[rule.strip()for rule in rules_file] # Skapar en lista av csv i @rules
  for i in range(len(rules)): # Loopar igenom listan @rules
    rule_list=rules[i].split(' ') 
    fw_add_rule=of.ofp_flow_mod()   
    fw_add_rule.match=of.ofp_match()
    fw_add_rule.match.dl_src=EthAddr(rule_list[0])
    fw_add_rule.match.dl_dst=EthAddr(rule_list[1])
    event.connection.send(fw_add_rule) # Installerar rules för src och dst MAC adresser vid ConnectionUp
  Switch(event.connection) # Gå till klass switch med event

def launch (): # Start
  core.openflow.addListenerByName("ConnectionUp", _handle_ConnectionUp) # Specifierar handler function för ConnectionUp