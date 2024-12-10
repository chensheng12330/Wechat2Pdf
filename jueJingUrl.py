# coding: utf-8
import os
import random

JonsList = ["wx", "qq", "360", "Firfox", "Safari", "Chrome"]
Url = "https://juejin.cn/post/7281159113882320915"
# 遍历 a 标签并打印 href 属性
for a in JonsList:
   
   randerStr = ''.join(random.sample(['z','y','x','w','v','u','t','s','r','q','p','o','n','m','l','k','j','i','h','g','f','e','d','c','b','a','1','2','3','4','5','6','7','8','9'], 10))
   NewUrl = Url + "?" + a + "=" + randerStr
   print(NewUrl)

