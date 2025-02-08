#!/usr/bin/env python
# -*- coding: utf-8 -*-

import ssl

import json
import urllib.request as request
import urllib.parse as parse

##### 自分の環境に合わせて編集してください #####
user = 'tier4.jp'
passwd = 'tier4'
dcaseID = "no58NkJvu366jusJSMypnstDt1_EOYr0J6Hrf8PSgsI_" # dcase_comのエディター画面のURLを参照
partsID = "Parts_fcx90cjb" # トップゴールのパーツID
userList = [] 
#############################################


baseURL = "https://www.matsulab.org/dcase/"


def main():
	authID = auth(user=user, passwd=passwd)
	print("authID", authID)
	ret = uploadEvalData(
			authID = authID,
			dcaseID = dcaseID,
			partsID = partsID,
			userList = userList, 
			paramList = [{"n":1,"Time":10,"suv_speed":4,"value_st":13.1,"status":"-"},{"n":1,"value_bt":1.94,"value_bd":4,"value_st":13.1,"status":"-"},],
		)
	print("ret", ret)

def auth(user, passwd):
	url = baseURL + '/api/login.php'
	postData = {
		'mail': user,
		'passwd': passwd,
	}
	ret = http_request(url, data=postData)
	return ret['authID']

def http_request(url, data):
	ctx = ssl.create_default_context()
	ctx.check_hostname = False
	ctx.verify_mode = ssl.CERT_NONE

	postData = parse.urlencode(data).encode('utf-8')
	headers = {
		'Content-Type': 'application/x-www-form-urlencoded',
	}
	print("ddd")
	print(postData)
	req = request.Request(url, postData, headers)
	res = request.urlopen(req, context=ctx)
	body = res.read().decode('utf-8')
	return( json.loads( body ) )

def uploadEvalData(authID, dcaseID, partsID, userList ,paramList):
	url = baseURL + '/api/uploadEvalData.php'
	postData = {
		'authID': authID,
		'dcaseID': dcaseID,
		'partsID': partsID,
		'userList': json.dumps(userList),
		'paramList': json.dumps(paramList),
	}
	ret = http_request(url, postData)	
	return ret

if __name__ == '__main__':
	main()