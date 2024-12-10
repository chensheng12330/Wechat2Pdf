# coding: utf-8
# 解析html标签下的所有 href, 生成json对象
import os
from bs4 import BeautifulSoup
import requests
import json

# 从指定的 URL 获取页面内容
# url = "/Volumes/Data/SherwinGitPro/Wechat2Pdf/GetAllUrl.html"
# response = requests.get(url)
#html_content = response.content

file = open('/Volumes/Data/SherwinGitPro/Wechat2Pdf/GetAllUrl.html').read()

html_content=file

# /Volumes/Data/SherwinGitPro/Wechat2Pdf/GetAllUrl.html

# 使用 BeautifulSoup 解析页面内容
soup = BeautifulSoup(html_content, "html.parser")

# 获取所有的 a 标签
a_tags = soup.find_all("a")

JonsList = []
# 遍历 a 标签并打印 href 属性
for a in a_tags:
    href = a.get("href")
    title = a.get("title")
    if href:
        JonsObj = {"href": href, "title": title}
        JonsList.append(JonsObj)
        
jsonStr = json.dumps(JonsList)
print(jsonStr)
