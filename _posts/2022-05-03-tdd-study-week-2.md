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

즉 어떤 시점에서 테스트를 진행하느냐에 따라 기능/단위 테스트로 나뉘고,<br>
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
