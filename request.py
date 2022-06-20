# -*- coding: utf-8 -*-
"""
Created on Sat Jun 18 18:24:05 2022

@author: Carlos Mejia
"""
import requests

def post_request():
    """"""
    # %%

    url = 'http://127.0.0.1:5000/InsertData'
    header = {
        "X-API-Key": 'Qwerty123*'        
    }

    data_json = 'True'

    print(f'Sending request to load trip data')

    resp = requests.post(url=url,
                         headers=header,
                         data=data_json)
    # 200 request was successful
    if resp.status_code != 200:
        print(resp)
        print(resp.content)
    else:
        print(f'request successful: {resp.content}')

if __name__ == '__main__':
    post_request()