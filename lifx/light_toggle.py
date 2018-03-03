#! /usr/bin/env python

from scapy.all import BOOTP, Ether, IP, sniff
import lifx
import time

def toggle_light():
  lights = lifx.Client()
  time.sleep(1)
  for l in lights.by_label('### DEVICE LABEL ###'):
    l.power_toggle(duration=100)

def bootp_display(pkt):
  if pkt[Ether].src == '### MAC ADDRESS ###':
    if pkt[BOOTP].op == 1:
      if pkt[IP].id == 1:
        now = time.strftime("%c")
        print ("%s"  % now ) + " - toggled"
        toggle_light()

print sniff(prn=bootp_display, filter="udp port 67", store=0)
