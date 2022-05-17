---
title: 'TDD Study : week 3'
---

### 부제 : 
<br>
참고서적 : `클린 코드를 위한 테스트 주도 개발(해리 J.W. 퍼시벌 저)`<br>
환경 : `Mac(M1)`, `Python 3.8.3`,  `Django 4.0.4`,  `Selenium 4.1.3`,  `Firefox`<br>
### Chapter 05. <br>
lists/templates/home.html에 아래 내용 추가

```html
<h1>Your To-Do list</h1>
<form method="POST">
    <input name="item_text" id="id_new_item" placeholder="Enter a to-do item" />
</form>

<table id="id_list_table">
```

에러메시지

```command
```

해결방법
* print를 활용해 현재 내용 출력
* 현재 상태를 더 잘 나타낼 수 있도록 error 메시지를 변경
* 직접 웹사이트를 들어가 보기
* time.sleep을 활용하여 테스트 중 일시정지 시키기<br>


time.sleep 활용하여 functional_tests.py 수정

```python
inputbox.send_keys(Keys.ENTER)

import time
time.sleep(10)
table = self.browser.find_element(by=By.ID, value='id_list_table')
```

에러 확인(CSRF 에러 예상)<br><br>

lists/templates/home.html 수정
```html
<form method="POST">
    <input name="item_text" id="id_new_item" placeholder="Enter a to-do item" />
    {/% csrf_token /%}
</form>
```
(여기서 {랑 % 붙여 쓴 것때문에 지킬 오류가 나서 중간에 \를 넣었음)<br><br>
에러메세지

```command
```

functional_tests.py 수정(time.sleep 삭제)

```python
inputbox.send_keys(Keys.ENTER)
table = self.browser.find_element(by=By.ID, value='id_list_table')
```

lists/tests.py 수정

```python
def test_home_page_returns_correct_html(self):
    [...]

def test_home_page_can_save_a_POST_request(self):
    request = HttpRequest()
    request.method = 'POST'
    request.POST['item_text'] = 'A new list item'
    
    response = home_page(request)
    self.assertIn('A new list item', response.content.decode())
```

에러메세지

```command
```

lists/views.py 수정

```python
from django.http import HttpResponse
from django.shortcuts import render

def home_page(request):
    if request.method == 'POST':
        return HttpResponse(request.POST['item_text'])
    return render(request, 'home.html')
```

lists/templates/home.html 수정

```html
<body>
    <h1>Your To-Do list</h1>
    <form method="POST">
        <input name="item_text" id="id_new_item" placeholder="Enter a to-do item" />
        {/% csrf_token /%}
    </form>
    <table id="id_list_table">
        <tr><td>{/{ new_item_text }\}</td></tr>
    </table>
</body>
```

lists/tests.py 수정

```python
self.assertIn('A new list item', response.content.decode())
expected_html = render_to_string(
    'home.html',
    {'new_item_text': 'A new list item'}
)
self.assertEqual(response.content.decode(), expected_html)
```

에러메세지

```command
```

lists/views.py 수정

```python
def home_page(request):
    return render(request, 'home.html', {
        'new_item_text': request.POST['item_text'],
    })
```

에러메세지

```command
```

lists/views.py 수정

```python
def home_page(request):
    return render(request, 'home.html', {
       'new_item_text': request.POST.get('item_text', ''),
    })
```

에러메세지

```command
```

functional_tests.py 수정

```python
self.assertTrue(
    any(row.text == '1: Buy peacock feathers' for row in rows),
        "New to-do item did not appear in table.. its text was:\n%s" %(
            table.text,
        )
    )
```

에러 메세지

```command
```

functional_tests.py 수정

```python
self.assertIn('1: Buy peacock feathers', [row.text for row in rows])
```

에러 메세지

```command
```

lists/templates/home.html 수정

```html
<tr><td>1: {{ new_item_text }}</td></tr>
```

functional_tests.py 수정

```python
```

에러 메세지

```command
```
