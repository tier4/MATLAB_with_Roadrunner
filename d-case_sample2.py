#!/usr/bin/env python
# -*- coding: utf-8 -*-

import ssl

import json
import urllib.request as request
import urllib.parse as parse

##### 自分の環境に合わせて編集してください #####
user = 'tier4.jp'
passwd = 'tier4'
dcaseID = "9JHFaybThTPVJdTo_LbzUJohOf55EHl63TaGEKg5Ok8_" # dcase_comのエディター画面のURLを参照
partsID = "Parts_9og3u26r" # トップゴールのパーツID
userList = [
	# 「メニュー」→「D-Caseの合意形成の投票」の「点数配分の設定」に表示されているユーザー名をクリックして取得
	"uaw_rebPBN_g9oDNrRmD0vs71jRfWeZ2HqZ_lu8idLE_", 
], 
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
			# paramList = {
			# 	"100":{
			# 		"param1":1,
			# 		"param2":2,
			# 		"param3":3,
			# 	},
			# 	"101":{
			# 		"param1":1,
			# 		"param2":2,
			# 		"param3":3,
			# 	},
			# 	"102":{
			# 		"param1":1,
			# 		"param2":2,
			# 		"param3":3,
			# 	},
			# }, 
			paramList = [{"n":1,"value_bt":1.94,"value_bd":4,"value_st":13.1,"status":"-"},{"n":1,"value_bt":1.94,"value_bd":4,"value_st":13.1,"status":"-"},],
		)
	print("ret", ret)


def http_request(url, data):
	ctx = ssl.create_default_context()
	ctx.check_hostname = False
	ctx.verify_mode = ssl.CERT_NONE

	postData = parse.urlencode(data).encode('utf-8')
	headers = {
		'Content-Type': 'application/x-www-form-urlencoded',
	}
	req = request.Request(url, postData, headers)
	res = request.urlopen(req, context=ctx)
	body = res.read().decode('utf-8')
	return( json.loads( body ) )


def auth(user, passwd):
	url = baseURL + '/api/login.php'
	postData = {
		'mail': user,
		'passwd': passwd,
	}
	ret = http_request(url, data=postData)
	return ret['authID']


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