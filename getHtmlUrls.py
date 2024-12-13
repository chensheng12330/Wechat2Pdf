import requests
from bs4 import BeautifulSoup
import json

def extract_links_to_json(url, output_file):
    try:
        # 发送HTTP请求获取页面内容
        response = requests.get(url)
        response.raise_for_status()  # 确保请求成功

        # 使用BeautifulSoup解析HTML
        soup = BeautifulSoup(response.text, 'html.parser')

        # 提取所有链接
        links = soup.find_all('a', href=True)

        # 构建JSON数据
        data = []
        for link in links:
            href = link['href']
            title = "No title"  # link['title']
            print(f"请求失败: {link}")
            # if not title:  # 如果title为空，设置为默认值
            #     title = "No title"
            data.append({"url": href, "title": title})

        # 保存到JSON文件
        with open(output_file, 'w', encoding='utf-8') as file:
            json.dump(data, file, indent=4, ensure_ascii=False)

        print(f"提取完成！数据已保存到 {output_file}")
    except requests.exceptions.RequestException as e:
        print(f"请求失败: {e}")
    except Exception as e:
        print(f"发生错误: {e}")

# 示例调用
if __name__ == "__main__":
    # input("https://www.hw100k.com/yingshi")
    target_url = "https://www.hw100k.com/yingshi"
    output_path = "links.json"  # 输出文件路径
    extract_links_to_json(target_url, output_path)
