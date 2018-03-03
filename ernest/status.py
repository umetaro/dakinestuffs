#!/usr/bin/python

from subprocess import call
import requests

post = requests.post('https://slack.com/api/users.getPresence', data = {'token': '### TOKEN HERE ###'})
response = post.json()

if response['online'] != bool(1):
    call(['/usr/bin/sudo', '/sbin/service', 'ernest', 'restart'])
