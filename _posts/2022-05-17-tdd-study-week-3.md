---
title: 'TDD Study : week 3'
---

### 부제 : 와 벌써부터 너무 길다 때려칠까? 아냐 그래도 1부까진 해야 아니 근데
<br>
참고서적 : `클린 코드를 위한 테스트 주도 개발(해리 J.W. 퍼시벌 저)`<br>
환경 : `Mac(M1)`, `Python 3.8.3`,  `Django 4.0.4`,  `Selenium 4.1.3`,  `Firefox`<br>
### Chapter 05. 사용자 입력 저장하기<br>
마치 폼 입력만 처리하는 것처럼 앙큼한 제목을 하고 있지만 30p에 달하는 길이의 챕터 5...<br>
더 끔찍한 건 챕터 6은 더 길다는 것이다... ㅎ...<br><br>

이번에 작업할 내용은 사용자가 입력한 작업 아이템을 서버로 보내고 이를 저장 -> 다시 사용자에게 보여주는 시스템이다. 이번에도 역시 한 번에 한 가지씩 진행하며, 테스트에 필요한 최소한의 기능만 구현한다. 이 과정에서 머리도 쓰지 말고 그냥 그대로 하나씩 따라하라고 대놓고 적혀있다. 정말 이대로 괜찮은지 싶지만 테스트염소 님이 그렇게 하란다니까 별 수 없지. 근데 왜 염소인지? 공부가 하기 싫으니 쓸데 없는 것만 궁금함. 분명히 별 의미 없겠지 파이썬이 몬티파이썬의 파이썬인 것처럼...<br><br>

아무튼 그렇다고 하니까 + 내용이 부연설명 추가하며 정리하기엔 너무 길고 나는 너무 지쳤기 때문에<br>
이번 챕터는 전보다 더 코드작성+테스트결과에만 집중해서 정리해보도록 하겠음.<br>
그 사이에 버전정보 등으로 나는 오류가 있다면 추가로 작성해 두도록 할 것임...<br>

먼저 POST 리퀘스트를 보내기 위한 폼을 작성해야 하므로 lists/templates/home.html에 아래 내용을 추가한다.

```html
<h1>Your To-Do list</h1>
<form method="POST">
    <input name="item_text" id="id_new_item" placeholder="작업 아이템 입력" />
</form>

<table id="id_list_table">
```

그 뒤에 기능테스트를 실행하니 아래와 같은 에러가 발생한다.

```command
selenium.common.exceptions.StaleElementReferenceException: Message: The element reference of <table id="id_list_table"> is stale; either the element is no longer attached to the DOM, it is not in the current frame context, or the document has been refreshed
```

앗... 책에는 NoSuchElementException이었는데 나는 다른 에러가 난다. 하지만 에러 위치는 동일한 것으로 보아 원인은 같은 것인가? 아무튼 책에서는 이렇게 예측 못한 에러가 발생할 시 아래와 같은 방법을 사용하라고 되어 있다.<br>

* print를 활용해 현재 페이지 텍스트 내용 출력
* 현재 상태를 더 잘 나타낼 수 있도록 error 메시지를 개선
* 수동으로 웹사이트를 열어보기
* time.sleep을 활용하여 실행 중인 테스트 일시정지 시키기<br>

여기서는 time.sleep을 활용하여 functional_tests.py를 수정해보도록 한다.<br>
에러가 발생하는 위치 앞에 time.sleep을 적는다.

```python
# 엔터키를 치면 페이지가 갱신되고 작업 목록에 해당 할일 내용이
# "1: 공작깃털 사기" 형식으로 추가된다
inputbox.send_keys(Keys.ENTER)

import time
time.sleep(10)
table = self.browser.find_element(by=By.ID, value='id_list_table')
```

다시 테스트를 돌리면 CSRF 에러가 난다. 화면을 캡쳐하고 싶지만 오늘도 힘이 없기 때문에...<br>
대충 아래와 같이 뜬다.

```command
Forbidden (403)
CSRF verification failed. Request aborted.
```

CSRF 오류를 해결하려면 템플릿단에서 csrf_token을 추가해주어야 한다.<br>
관련하여 상세히 알고 싶으신 분들은 django csrf 보안 관련 글들을 찾아보시기를 권함...<br>
아무튼 아래와 같이 lists/templates/home.html를 수정하는데<br>
원래는 { 다음에 바로 %가 와야 하지만 지킬에서 이상하게 오류가 나서 중간에 \를 넣었다.<br>
그리고 여기서 갑자기 예문 플레이스홀더 내용이 영문으로 변경되어 있는데 이건 번역을 덜 하셔서 그런 듯...<br>
나는 한글 상태로 그대로 두었다.

```html
<form method="POST">
    <input name="item_text" id="id_new_item" placeholder="작업 아이템 입력" />
    {/% csrf_token %}
</form>
```
그리고 다시 기능테스트 실행

```command
AssertionError: False is not true : 신규 작업이 테이블에 표시되지 않는다
```

이것은 time.sleep이 남아있어서 그렇다고 함. 다시 functional_tests.py로 가서 time.sleep을 삭제해 준다.

```python
inputbox.send_keys(Keys.ENTER)
table = self.browser.find_element(by=By.ID, value='id_list_table')
```

<br>
다음은 POST요청 처리 부분으로 넘어간다.<br>
lists/tests.py의 HomePageTest 클래스에 POST 요청 처리와 반환된 HTML이 신규 아이템 텍스트를 포함하고 있는지 확인하는 새로운 메소드를 추가한다.

```python
def test_home_page_returns_correct_html(self):
    [...]

def test_home_page_can_save_a_POST_request(self):
    request = HttpRequest()
    request.method = 'POST'
    request.POST['item_text'] = '신규 작업 아이템'
    
    response = home_page(request)
		
    self.assertIn('신규 작업 아이템', response.content.decode())
```

이후에 단위테스트를 실행하면

```command
AssertionError: '신규 작업 아이템' not found in '<html>\n    <head>\n        <title>To-Do lists</title>\n    </head>\n    <body>\n        <h1>Your To-Do list</h     <form method="POST">\n            <input name="item_text" id="id_new_item" placeholder="작업 아이템 입력" />\n            <input type="hidden" name="csrfmietoken" value="a7A5DZgmw6TM6CnlXLRr4c8QNUYyUIU9TmS9w5XJtDbf69UuRoHFxkmzanbHT9iL">\n        </form>\n        <table id="id_list_table">\n        </table>\n    </body>\n</html>'
```

아니 왜케 길어<br>
아무튼 어설션 에러가 발생한다. 이제 lists/views.py에 아래처럼 if문을 추가한다.

```python
from django.http import HttpResponse
from django.shortcuts import render

def home_page(request):
    if request.method == 'POST':
        return HttpResponse(request.POST['item_text'])
    return render(request, 'home.html')
```

그리고 lists/templates/home.html 파일에 아래처럼 아이템 내용을 추가한다.<br>
여전히 오류 방지를 위해 { 뒤에 \를 추가했다.

```html
<body>
    <h1>Your To-Do list</h1>
    <form method="POST">
        <input name="item_text" id="id_new_item" placeholder="Enter a to-do item" />
        {/% csrf_token %}
    </form>
    <table id="id_list_table">
        <tr><td>{/{ new_item_text }}</td></tr>
    </table>
</body>
```

그 다음 lists/tests.py 로 돌아와서 내용을 추가한다.

```python
self.assertIn('A new list item', response.content.decode())
expected_html = render_to_string(
    'home.html',
    {'new_item_text': 'A new list item'}
)
self.assertEqual(response.content.decode(), expected_html)
```

단위테스트에 대한 에러메세지는 여전하다. 뷰처리가 없기 때문이다.

```command
AssertionError: '신규 작업 아이템' != '<html>\n    <head>\n        <title>To-Do [329 chars]tml>'
```

그럼 이제 lists/views.py 파일을 수정한다.

```python
def home_page(request):
    return render(request, 'home.html', {
        'new_item_text': request.POST['item_text'],
    })
```

그 다음 이번엔 기능테스트를 돌리면 아래와 같은 에러가 난다.

```command
KeyError: 'item_text'
```

책이랑은 다르게 생기긴 했는데 동일한 위치에 대한 키 에러다.<br>
예상치 못한 결과로 POST 요청 처리를 하는 코드가 잘못됐다는 뜻이라고 한다.<br>
lists/views.py를 다시 수정한다.

```python
def home_page(request):
    return render(request, 'home.html', {
       'new_item_text': request.POST.get('item_text', ''),
    })
```

코드가 POST.get 방식으로 변경된 것을 볼 수 있다.<br>
기능테스트 결과는 아래와 같다.

```command
selenium.common.exceptions.StaleElementReferenceException: Message: The element reference of <table id="id_list_table"> is stale; either the element is no longer attached to the DOM, it is not in the current frame context, or the document has been refreshed
```

떼잉<br>
오류 메시지가 책이랑 전혀 다른데 일단은 책에서 시킨대로 functional_tests.py에 오류 메시지 개선사항을 넣는다.<br>
이 과정에서 assertTrue로 되어있던 것을 assertIn으로 변경했다.

```python
self.assertIn('1: 공작깃털 사기', [row.text for row in rows])
```

그리고 lists/templates/home.html도 임시적으로 아래와 같이 수정한다.

```html
<tr><td>1: {/{ new_item_text }}</td></tr>
```

당연하게도 나의 에러는 개선이 되지 않았음... 떼잉<br>
