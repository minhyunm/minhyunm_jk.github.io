---
title: 'TDD Study : week 2'
---

### 부제 : 이건... 뭐야...? 도자기 깨는 장인이야...?
<br>
참고서적 : `클린 코드를 위한 테스트 주도 개발(해리 J.W. 퍼시벌 저)`<br>
환경 : `Mac(M1)`, `Python 3.8.3`,  `Django 4.0.4`,  `Selenium 4.1.3`,  `Firefox`<br>
### Chapter 03. 단위 테스트를 이용한 간단한 홈페이지 테스트<br>
<br>
앞서 진행한 내용에 좀 더 살을 붙여보도록 하겠다.<br>
지난 기능 테스트에 작성했듯이 타이틀에 'To-Do'라는 문구를 넣어주는 내용도 아마... 추가되겠지?<br>
그리고 무엇보다 이번 챕터에서는 앱 단위로 개발 테스트를 진행한다.<br>
즉 단위 테스트(Unit test)를 작성한다!<br>
이쯤에서 잠깐... 단위 테스트와 기능 테스트의 정확한 차이점이 무엇인지를 짚고 넘어가 보도록 하자.<br>
<br>
#### 단위 테스트 vs 기능 테스트<br>
* 기능 테스트 : 사용자 관점에서 애플리케이션 외부를 테스트<br>
* 단위 테스트 : 프로그래머 관점에서 애플리케이션 내부를 테스트<br>

어떤 시점에서 테스트를 진행하느냐에 따라 기능/단위 테스트로 나뉘고,<br>
때문에 기능 테스트와 단위 테스트는 테스트 스토리부터 방식, 테스트 대상이 차이가 날 수밖에 없다.<br>
이전까지 이 둘의 개념이 좀 모호했는데 이렇게 보니 굉장히 확연히 다른 개념이었던 것이다...<br>
아는 만큼 보인다고... 공부 열심히 해야지... 기승전공부...<br>
<br>
아무튼 그리하여 이 책을 통해 우리가 개발해나가는 방식은 아래와 같은 순서로 이루어질 예정이다.<br>
1. 기능테스트 작성(사용자 관점의 기능성을 정의)<br>
2. 기능 테스트가 실패하는 것을 확인 -> 어떤 코드로 테스트를 통과시킬 수 있을지에 대해 고민 -> 단위 테스트를 작성하여 코드가 동작해야 하는 방향성을 정의<br>
3. 단위 테스트가 실패하는 것을 확인 -> 단위 테스트를 통과할 수 있을 정도의 최소한의 코드를 작성 -> 반복(기능 테스트가 완전해질 때까지)<br>
4. 기능 테스트 재실행하여 동작여부 확인(이 단계에 단위 테스트를 추가로 작성해야 할 수 있음)<br>

즉 기능 테스트는 상위 레벨의 개발을, 단위 테스트는 하위 레벨의 개발을 주도한다.<br>
전체 플로우와 이에 대한 적합성 여부를 판단하는 것은 기능 테스트, 그리고 각 내용 하나하나가 정상동작하는지를 확인하는 것은 단위 테스트라고 생각할 수 있겠다.<br><br>

그럼 이제 슬슬 작업할 앱을 생성해 보자.<br>

```python
python manage.py startapp lists
```
앱 이름은 책에서 진행한 내용과 동일하게 lists로 넣어봤다.<br>

그 다음은 단위 테스트를 작성할 차례다.<br>
startapp 명령어를 통해 자동 생성된 lists 앱 내부의 파일 중에서 tests.py를 눌러본다. 물론 지금은 django.test에서 TestCase를 임포트한 내용 말고는 아무 것도 적혀있지 않다. 이 TestCase는 앞서 사용했던 unittest.TestCase의 확장 버전이다. 이 파일에 고의적인 실패 테스트를 만들어 본다.<br>
 ```python
from django.test import TestCase


class SmokeTest(TestCase):

    def test_bad_maths(self):
        self.assertEqual(1 + 1, 3)
```
내용을 보아하니 1+1과 3이 동일한 값인지를 확인하는 테스트인 듯하다.<br>
이제 아래의 명령어를 입력하면 테스트를 진행한다.
```python
python manage.py test
```
1+1이 3일리 없으니 이 테스트는 반드시 오류를 리턴하게 되어 있다.<br>
```command
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
F
======================================================================
FAIL: test_bad_maths (lists.tests.SmokeTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/Users/minh/PycharmProjects/tdd_study/superlists/lists/tests.py",
	line 7, in test_bad_maths
    self.assertEqual(1 + 1, 3)
AssertionError: 2 != 3

----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (failures=1)
Destroying test database for alias 'default'...

```
굳<br>
<br>
그럼 이제 앱 내용을 작성해야 한다.<br>
장고가 어떠한 요청을 받아 처리하는 과정은<br>
1. 특정 url에 대한 http request를 받음<br>
2. 특정 규칙을 이용해 해당 request에 맞는 view 함수를 결정(url 해석)<br>
3. 요청을 처리하여 http response로 반환<br>

와 같으므로 우리가 테스트해야 할 내용은 해당 url의 해석이 제대로 이루어지는지 & 올바른 html를 반환하여 기능테스트를 통과하는지 의 두 가지이다.<br>
<br>
이에 맞는 테스트코드를 작성해 본다.<br>
```python
from django.urls import resolve
from django.test import TestCase
from lists.views import home_page


class SmokeTest(TestCase):

    def test_root_url_resolves_to_home_page_view(self):
        found = resolve('/')
        self.assertEqual(found.func, home_page)
```
여기서 첫 번째 줄은 from django.core.urlresolvers import resolve 라고 되어있었는데<br>
이게 장고 1.x 버전대 코드라 수정을 해주었다.<br>
이 내용은 대략 url로 '/'가 호출되면 resolve를 실행하여 home_page라는 함수를 호출하라는 내용이다.<br>
그 후 해당 함수가 home_page 함수가 맞는지를 확인하는 코드가 들어간다.<br>
이제 코드를 실행하면 오류 메시지는 ImportError: cannot import name 'home_page' from 'lists.views' 라고 뜬다.<br>
아직 home_page라는 함수를 만든 적이 없으니 당연하다.<br>
<br>
문제는 여기서부터이다. 책에서는 지금부터 본격 TDD의 시작이기 때문에 한 번에 한 줄의 코드만 수정해 갈 것이라고 적혀 있다.<br>
벌써부터 속이 터진다. 하지만 별 수 없지.<br>
<br>
먼저 시급한 문제인 home_page 함수의 부재를 처리해본다.
```python
from django.shortcuts import render

# Create your views here.
home_page = None
```
앗 예상치 못했던 진행이다.<br>
TDD란 이렇게 언 발에 오줌 누기 형식으로 진행되는 것이란 말인가<br>
아무튼 다시 테스트를 돌리니 당연하지만 오류 메시지가 바뀌어 있다.
```command
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
E
======================================================================
ERROR: test_root_url_resolves_to_home_page_view (lists.tests.SmokeTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/Users/minh/PycharmProjects/tdd_study/superlists/lists/tests.py", 
	line 9, in test_root_url_resolves_to_home_page_view
    found = resolve('/')
  File "/opt/homebrew/Caskroom/miniforge/base/envs/tdd_study/lib/python3.8/
	site-packages/django/urls/base.py", line 24, in resolve
    return get_resolver(urlconf).resolve(path)
  File "/opt/homebrew/Caskroom/miniforge/base/envs/tdd_study/lib/python3.8/
	site-packages/django/urls/resolvers.py", line 683, in resolve
    raise Resolver404({"tried": tried, "path": new_path})
django.urls.exceptions.Resolver404: {'tried': [[<URLResolver <URLPattern 
list> (admin:admin) 'admin/'>]], 'path': ''}

----------------------------------------------------------------------
Ran 1 test in 0.001s

FAILED (errors=1)
Destroying test database for alias 'default'...
```
해당 url 패턴이 지정되어 있지 않기 때문에 오류가 난 것으로 확인된다.<br>
그렇겠지 urls를 안 건드렸으니까...<br>
그래서 이번에는 urls를 수습하러 떠난다.<br>
```python
from django.contrib import admin
from django.urls import path

urlpatterns = [
    # path('admin/', admin.site.urls),
    path(r'^$', 'superlists.views.home', name='home'),
]
```
이번에도 변함없이 책에는 1.x 버전 장고에 맞춘 코드예제가 나와 있었는데 예를 들면<br>
include, url, patterns 같은 것들...<br>
include는 2버전대에서도 종종 써봤지만 아무튼<br>
patterns는 생략해도 제대로 작동하도록 바뀌었으므로 제거하고, url은 path로 대치하여 코드를 작성했다.<br>
대충 url로 빈 문자열이 전달될 경우 home이라는 view 함수를 찾아가도록 만드는 내용이다.<br>
이대로 테스트를 돌리면 이제 또 에러 메시지가 바뀌어 있다.<br>
```command
TypeError: view must be a callable or a list/tuple in the case of include().
```
이번 에러메시지 너무 길어서 마지막 줄만 긁어옴; 이번은 타입에러다.<br>
근데 책에 나온 에러는 import error였기 때문에... 뭔가 버전차이가 또 있겠거니<br>
일단 내 에러메시지의 원인은 urls에서 view 연결하는 부분인 것으로 보여서<br>
책에 나온 import error랑 같이 뚝딱뚝딱 또 고쳐봤다.<br>
(정규식이 사라진 이유는 버전차이 때문인지 그걸로 계속 오류가 나서...ㅠ)<br>
```python
from django.contrib import admin
from django.urls import path
from lists.views import home_page

urlpatterns = [
    # path('admin/', admin.site.urls),
    path('', home_page, name='home'),
]
```
home_page가 계속 None 상태면 또 오류가 날 것이 분명하므로 이번에는 이쪽도 바꿔준다.<br>
```python
from django.shortcuts import render

# Create your views here.
def home_page():
    pass
```
그리고 드디어 테스트를 통과했다.<br>

```command
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
.
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
Destroying test database for alias 'default'...
```
<br>
이제 url을 통한 접근에 문제가 없음을 확인했으니 이번엔 응답을 위한 단위 테스트를 작성할 차례다.<br>
이번 테스트는 HTML 형식의 실제 응답을 반환하는 함수를 작성해야 한다.<br>
lists/tests.py 내용을 아래와 같이 고친다.<br>
```python
from django.urls import resolve
from django.test import TestCase
from django.http import HttpRequest

from lists.views import home_page


class HomePageTest(TestCase):

    def test_root_url_resolves_to_home_page_view(self):
        found = resolve('/')
        self.assertEqual(found.func, home_page)

    def test_home_page_returns_correct_html(self):
        request = HttpRequest()
        response = home_page(request)
        self.assertTrue(response.content.startswith(b'<html>'))
        self.assertIn(b'<title>To-Do lists</title>', response.content)
        self.assertTrue(response.content.endswith(b'</html>'))
```
<br>
SmokeTest로 되어있던 클래스명을 HomePageTest로 변경하고, 임포트에 HttpRequest를 추가했다.<br>
그리고 test_home_page_returns_correct_html이라는 함수를 추가했는데, 이 함수는

1. HttpRequest 객체를 생성하여 사용자가 어떤 요청을 브라우저에 보냈는지 확인<br>
2. 요청을 home_page 뷰에 전달하여 응답을 취득(HttpResponse 인스턴스)<br>
3. 응답 내용이 특정 html 코드를 가지고 있는지 확인(title 내용에 To-Do lists가 들어있는지 여부 포함)

의 내용을 담고 있다.<br>
앞서 정리한 대로 단위 테스트는 기능 테스트에 의해 파생된 하위 개념이기 때문에<br>
더 상세하고, 실제 코드에 가깝다. 즉 프로그래머의 입장에서 진행해야 한다.<br>
<br>
아무튼 위의 테스트를 실행하면 아래의 에러가 뜬다.<br>
```command
TypeError: home_page() takes 0 positional arguments but 1 was given
```
이제 코드의 에러를 한 줄 한 줄 해결해 나갈 차례다.<br>
오류를 수정하기 위한 최소한의 코드를 변경한 뒤 테스트를 재실행하기를 반복해 나가야 한다.<br>
책에서는 이 부분을 단위테스트 코드 주기라고 표시했는데,<br>
개념적으로 볼 때 한 줄씩 코드를 수정해 테스트한 뒤 적용하는 것은 나노 주기,
단위테스트 단위로 코드를 수정 후 적용하는 것은 RGR 주기라고 이해하고 있어서<br>
솔직히 여기서 말하는 주기가 어떤 건지 헷갈린다.<br>
아무튼 시키는 대로 코드 수정을 시작해보도록 한다.<br><br>

코드 수정 : home_page()에 파라미터로 request를 추가한다
```python
def home_page(request):
    pass
```

테스트 결과
```command
self.assertTrue(response.content.startswith(b'<html>'))
AttributeError: 'NoneType' object has no attribute 'content'
```

코드 수정 : django.http.HttpResponse를 임포트하여 리턴
```python
from django.http import HttpResponse

def home_page(request):
    return HttpResponse()
```

테스트 결과
```command
self.assertTrue(response.content.startswith(b'<html>'))
AssertionError: False is not true
```

코드 수정 : 리턴 내용에 html 코드 추가
```python
def home_page(request):
    return HttpResponse('<html><title>To-Do lists</title>')
```

테스트 결과
```command
self.assertTrue(response.content.endswith(b'</html>'))
AssertionError: False is not true
```

코드 수정 : 리턴 코드에 `</html>` 추가
```python
def home_page(request):
    return HttpResponse('<html><title>To-Do lists</title></html>')
```

테스트 결과
```command
Ran 2 tests in 0.001s

OK
Destroying test database for alias 'default'...
```
<br>
야호!<br>
왜인지 모르겠지만 책보다 일찍 테스트를 통과했는데 어디서 잘못 썼는지 모르겠고 의도는 파악했으므로 다 된 것으로 여기겠음.<br>
자 그럼 기존에 작성했던 functional_tests.py를 다시 실행해보도록 하겠다.<br>
```python
python functional_tests.py
```

테스트 결과
```command
F
======================================================================
FAIL: test_can_start_a_list_and_retrieve_it_later (__main__.NewVisitorTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "functional_test.py", line 22, in test_can_start_a_list_and_retrieve_it_later
    self.fail('Finish the test!')   # 강제로 테스트 실패 발생시키기
AssertionError: Finish the test!

----------------------------------------------------------------------
Ran 1 test in 1.282s

FAILED (failures=1)
```
성공! Failed로 뜨는 부분은 브라우저 종료를 위해 심어둔 강제 실패때문에 그렇다.<br>
이 과정에 놀랍게도 또 한 차례 오류를 겪었는데 서버가 내려가있는 걸 까먹고 진행해서...<br>
다들 런서버를 까먹지 맙시다!<br>
<br>
### Chapter 04. 왜 테스트를 하는 것인가?<br>
챕터 4의 소제목이 갑자기 뜬금없이 원론적인 질문인 이유는 아마도<br>
이 쯤에서 한 줄씩 마이크로 수정을 거치는 방식에 회의감을 느끼고 TDD 때려칠까 고민하는 나 같은 사람들을 위해(역시 나만 그런 게 아니었지) 저자가 친절한 설명을 곁들였기 때문일 것이다(이 내용에 약 3p를 할애하심).<br>
대략 요약하면 지금 고생해 두면 테스트가 나를 대신해 궂은 일들을 해줄 것이다,<br>
TDD를 익히는 것은 훈련이 필요하기 때문에 자잘한 내용부터 시작해야 한다,<br>
테스트의 틀을 잘 만들어두면 새로운 테스트를 추가할 때 활용하기 좋다 기타등등.<br>
맞는 말임을 알면서도 한 편으론 약간 도자기 깨는 장인이 하는 소리 같다는 생각을 떨칠 수가 없는데<br>
그래 뭐... 나만 그런 게 아니라니 아무튼 힘을 내 본다.<br>
<br>
아무튼 다시 테스트로 돌아가서...<br>
챕터 3에 진행한 내용에다가 이어서 코드를 짜야 하기 때문에 저자는 런서버를 통해 서버를 가동할 것을 강조한다. 바로 열댓 줄 위에 똑같은 소리를 했었기 때문에 약간 인제 야너두 상태가 되면서 나 자신을 너그럽게 봐주게 됨<br>
자 그럼 이제 이어서 테스트를 마무리해 보자. 코드를 손봐야 한다.<br>
책 내용대로라면 대충 키 입력 처리를 위한 임포트문 하나가 늘어났고 중간에 h1 내용 확인하는 항목 포함 상세 항목들이 추가됐다.<br>
자 근데<br>
오류없이 한 방에 수정이 될 리가<br>
없죠<br>
이제 라이브러리 함수 뭐 하나 칠 때마다 호환 안 될까봐 심장이 쫄깃해짐 근데 웃긴건 그 예감 틀리지를 않음<br>
아니나다를까 find_element_by_tag_name에 줄이 쫙쫙 가는 것이다.<br>
대충 보니까 함수 형태가 이제 바뀐 모양임...<br>
find_element(by=By.TAG_NAME, value='값') 으로 바꿔달라고 하니 참고하시면 좋을듯 (import도 하나 더 추가해야 함...)<br>
그리하여 결과적으로 아래와 같은 코드를 작성하게 된다.<br>

```python
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
import unittest


class NewVisitorTest(unittest.TestCase):
    # 테스트 시작 전에 자동호출되는 특수 메소드
    def setUp(self):
        self.browser = webdriver.Firefox()
        self.browser.implicitly_wait(3)     # 암묵적 대기 3초(로딩대기)

    # 테스트 완료 후에 자동호출되는 특수 메소드
    def tearDown(self):
        self.browser.quit()

    # test로 시작하는 모든 메소드는 테스트 메소드이며 클래스당 하나 이상의 테스트 메소드 작성 가능
    def test_can_start_a_list_and_retrieve_it_later(self):
        # 유저가 웹사이트를 확인한다
        self.browser.get('http://localhost:8000')

        # 웹 페이지 타이틀과 헤더가 'To-Do'를 표시하고 있다
        self.assertIn('To-Do', self.browser.title)  # 테스트용 어설션을 위해 assertIn 사용
        header_text = self.browser.find_element(by=By.TAG_NAME, value='h1').text
        self.assertIn('To-Do', header_text)

        # 유저가 작업을 추가하기로 한다
        inputbox = self.browser.find_element(by=By.ID, value='id_new_item')
        self.assertEqual(
            inputbox.get_attribute('placeholder'),
            '작업 아이템 입력'
        )

        # 할일 내용을 텍스트 상자에 입력한다 (예: 공작깃털 사기)
        inputbox.send_keys('공작깃털 사기')
        
        # 엔터키를 치면 페이지가 갱신되고 작업 목록에 해당 할일 내용이
        # "1: 공작깃털 사기" 형식으로 추가된다
        inputbox.send_keys(Keys.ENTER)
        
        table = self.browser.find_element(by=By.ID, value='id_list_table')
        rows = table.find_elements(by=By.TAG_NAME, value='tr')
        self.assertTrue(
            any(row.text == '1: 공작깃털 사기' for row in rows),
        )

        # 추가 아이템을 입력할 수 있는 여분의 텍스트 상자가 존재한다
        # 다른 할일을 입력한다(예: "공작깃털을 이용해서 그물 만들기")
        self.fail('Finish the test!')  # 강제로 테스트 실패 발생시키기

[...]
```
위의 내용을 테스트해 보면 h1을 찾지 못해서 아래와 같은 오류가 뜬다.<br>
```command
selenium.common.exceptions.NoSuchElementException: Message: Unable to locate element: h1
Stacktrace:
WebDriverError@chrome://remote/content/shared/webdriver/Errors.jsm:183:5
NoSuchElementError@chrome://remote/content/shared/webdriver/Errors.jsm:395:5
element.find/</<@chrome://remote/content/marionette/element.js:300:16
```
여기까지 왔으면 테스트는 제대로 작성한 것이고 이에 맞춰 코드를 수정해야 한다.<br>
그런데 이쯤에서 떠올려야 할 규칙사항 : <b>상수는 테스트하지 마라</b><br>
이것은 단위 테스트를 할 때의 일반적인 규칙 중 하나라고 한다. 다들 나만 빼고 언제 그런 규칙을... 정한 거야...?<br>
정리하자면 로직이나 흐름 제어, 설정 등을 테스트하기 위한 단위 테스트에서 특정 문자열을 체크하는 것이 의미가 없기 때문이라고 한다. 이런 경우는 템플릿을 이용하여 구문 검증을 하는 편이 더 효율적이라고. 듣고 보니 그러하다.<br>
<br>
이런 설명이 구구절절 나온 것은 당연하게도 모두 템플릿 테스트 코드를 작성하기 위한 밑밥이다.<br>
지금부터 템플릿을 사용하기 위한 리팩터링(Refactoring, 기능을 바꾸지 않고 코드 자체를 개선하는 작업)에 들어간다.
지금까지도 충분히 한 줄씩 수정을 해 왔지만, 리펙터링 작업을 할 때는 기존에 잘 되던 기능이 바뀌면 안 되기 때문에 특히 더더욱 조심해서 한 번에 한 가지씩만 수정을 해야 한다고 하니 참고하자.<br>
<br>
리펙터링을 진행하기 위해서는 먼저 그 자체로 이미 테스트를 무사히 통과하는 코드가 필요한데<br>
우리의 코드는 알다시피 테스트를 통과했다. 따라서 작업내용을 표시할 템플릿 파일을 만들러 간다.<br>
<br>
지금까지 작업한 lists 앱 폴더 하위에 templates 폴더를 생성하고, home.html 파일을 만든다.<br>
```html
<html>
    <title>To-Do lists</title>
</html>
```
그리고 views.py 파일에도 렌더 페이지 부분을 추가해 준다.
```python
from django.shortcuts import render
from django.http import HttpResponse


def home_page(request):
    return render(request, 'home.html')
```
그리고 `python manage.py test`로 확인해 본다.
```command
======================================================================
ERROR: test_home_page_returns_correct_html (lists.tests.HomePageTest)
----------------------------------------------------------------------
...
    raise TemplateDoesNotExist(template_name, chain=chain)
django.template.exceptions.TemplateDoesNotExist: home.html

----------------------------------------------------------------------
Ran 2 tests in 0.002s

```
중간에 상세한 오류는 생략하고... 대략적으로 템플릿을 못 찾는다는 의미임<br>
왜 못찾느냐 그것은 우리가 settings.py를 손대지 않았기 때문이다.<br>
장고 좀 건드려 본 사람들은 모두 아는 국룰 제1항 그것은 INSTALLED_APPS에 앱이름 추가하기...<br>
이 책은 이제까지 현란한 한 줄 코드 수정을 선보이며 나의 혼을 쏙 빼놓아서 앱 추가조차 까먹게 만들고는... 이제 와서 앱을 추가 안 했잖니^^라며... 나를 놀린 것이다... 농락당한 기분인걸...? 
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'lists',
]
```
옜소<br>
이제 됐겠지?
```command
----------------------------------------------------------------------
Ran 2 tests in 0.001s

OK
```
됐당<br>
다음은 상수를 테스트하지 않고 템플릿을 이용해서 렌더링하는 것을 테스트하도록 수정해주어야 하...는데 장고의 render_to_string을 쓰면 쉽다고 한다. lists/tests.py 파일을 다음과 같이 수정한다.
```python
from django.urls import resolve
from django.test import TestCase
from django.http import HttpRequest
from django.template.loader import render_to_string

from lists.views import home_page

class HomePageTest(TestCase):

    def test_root_url_resolves_to_home_page_view(self):
        found = resolve('/')
        self.assertEqual(found.func, home_page)

    def test_home_page_returns_correct_html(self):
        request = HttpRequest()
        response = home_page(request)
        expected_html = render_to_string('home.html')
        self.assertEqual(response.content.decode(), expected_html)
```
리스폰스 콘텐트의 바이트 데이터를 .decode() 함수를 써서 유니코드로 변환하고, 문자열 대 문자열로 비교를 거친다. 여기서 중요한 점은 상수가 아닌 구현 결과물을 비교하는 것이다.<br>
단위 테스트 수정이 끝났다면 이제 다시 home.html 템플릿에 부족한 내용을 추가하러 간다.
```html
<html>
    <head>
        <title>To-Do lists</title>
    </head>
    <body>
        <h1>Your To-Do list</h1>
    </body>
</html>
```
기본적인 구조 추가와 더불어 h1 태그를 추가해 주었다. 이제 기능 테스트를 다시 돌려 보면
```command
selenium.common.exceptions.NoSuchElementException: Message: 
Unable to locate element: [id="id_new_item"]
```
그려 고마우이<br>
다음 내용을 수정한다.
```html
<html>
    <head>
        <title>To-Do lists</title>
    </head>
    <body>
        <h1>Your To-Do list</h1>
        <input id="id_new_item" />
    </body>
</html>
```
다시 테스트
```command
Traceback (most recent call last):
  File "functional_tests.py", line 29, 
	in test_can_start_a_list_and_retrieve_it_later
    self.assertEqual(
AssertionError: '' != '작업 아이템 입력'
+ 작업 아이템 입력
```
아니 망할 거 알면서 테스트 돌려야 하는 과정 너무 스트레스다<br>
아무튼 다음 내용을 고치러 간다.
```html
<html>
    <head>
        <title>To-Do lists</title>
    </head>
    <body>
        <h1>Your To-Do list</h1>
        <input id="id_new_item" placeholder="작업 아이템 입력" />
    </body>
</html>
```
테스트 결과
```command

selenium.common.exceptions.NoSuchElementException: 
Message: Unable to locate element: [id="id_list_table"]
```
그려 고마우이...<br>
이제 테이블을 추가한다.
```html
<html>
    <head>
        <title>To-Do lists</title>
    </head>
    <body>
        <h1>Your To-Do list</h1>
        <input id="id_new_item" placeholder="작업 아이템 입력" />
        <table id="id_list_table">
        </table>
    </body>
</html>
```
테스트 결과
```command
Traceback (most recent call last):
  File "functional_tests.py", line 43, in test_can_start_a_list_and_retrieve_it_later
    self.assertTrue(
AssertionError: False is not true
```
으잉 갑자기 이건 뭐지<br>
다행히 책에도 똑같은 에러가 나고 있다. 오류 내용을 명확히 보기 위해 기능 테스트 파일의 assertTrue 함수에 실패 메시지를 정의해 준다.
```python
[...]
rows = table.find_elements(by=By.TAG_NAME, value='tr')
        self.assertTrue(
            any(row.text == '1: 공작깃털 사기' for row in rows),
            "신규 작업이 테이블에 표시되지 않는다"
        )
[...]
```
다시 테스트
```command
AssertionError: False is not true : 신규 작업이 테이블에 표시되지 않는다
```
야쓰<br>
이 내용은 폼 제출 처리를 구현해야 하기 때문에 다음 챕터로 넘어간다.<br>
길었던 3-4챕터가 이렇게 마무리되고... 나의 하루도... 마무리된다... 이제 잘 수 있어...<br>
