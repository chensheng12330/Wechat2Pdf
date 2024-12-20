# coding: utf-8
import pdfkit
import os
import requests
import logging
from bs4 import BeautifulSoup

#来源:  https://www.jianshu.com/p/c287c7481eb6
# 模板html,微信抓取到的html内容过多.
T_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="referrer" content="never">
    <meta name="referrer" content="no-referrer">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>{style}</style>
</head>
<body>
    {content}
</body>
</html>"""

# pdf的一些参数
PDF_OPTIONS = {
    'page-size': 'A4',
    'encoding': "UTF-8",
}


def getHtmlContent(url, proxies=None):
    '''
    获取html
    '''
    if proxies is None:
        proxies = {"http": None, "https": None}
    res = requests.get(url, proxies)
    res.encoding = 'utf-8'
    #printf("%s", res.text)
    #logging.debug(res.text)
    return res.text


def reHtmlTags(cnt_html):
    '''
    替换图片src、元素、删除元素
    '''
    # 替换图片标签属性
    cnt_html = cnt_html.replace(
        "data-src", "src").replace('style="visibility: hidden;"', "")
    soup = BeautifulSoup(cnt_html, 'html.parser')

    # 删除评论和投票的html标签
    if soup.iframe:
        soup.iframe.decompose()

    # 用模板格式化
    comments = soup.findAll("img", {"class": "like_comment_pic"})
    styles = soup.find_all('style')
    content = soup.find('div', id='page-content')
    fmt_html = T_HTML.format(style=styles[0].text, content=content)
    html = fmt_html.replace(comments[0].attrs['src'], '') if comments else fmt_html
    return html


def outFile(data, out_type):
    '''
    导出
    '''
    if out_type == 'pdf':
        pdfkit.from_string(data, '大米评测_文章.pdf', PDF_OPTIONS)
    else:
        path = os.getcwd() + '\\大米评测_文章.html'
        with open(path, 'w', encoding='utf-8') as f:
            f.write(data)


source = getHtmlContent('https://mp.weixin.qq.com/s?__biz=MzAxNDAyMzc0Mg==&mid=2683469402&idx=1&sn=d3e9c434091bb1fffc769a0827f424b2&chksm=819f730bb6e8fa1d02390339320f22bab34f877d7061d44f92206064dccbf9f9aefe6acba19d&scene=21#wechat_redirect')
html = reHtmlTags(source)
outFile(html, 'html')
outFile(html, 'pdf')
