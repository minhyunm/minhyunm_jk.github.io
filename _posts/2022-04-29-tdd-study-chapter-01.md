---
title: 'TDD Study : week 1'
---

### 부제 : 아니 그게 아니고 나는 파이어폭스를 안 써서 그래서 그런 거거든
<br>
참고서적 : `클린 코드를 위한 테스트 주도 개발(해리 J.W. 퍼시벌 저)`<br>
환경 : `Mac(M1)`, `Python 3.8.3`,  `Django 4.0.4`,  `Selenium 4.1.3`<br>
<br>
각 챕터에 필요한 라이브러리들은 미리 설치를 하고 진행했다.<br>
셀레니움의 경우 버전 정보가 따로 보이지 않아서 그냥 최신 버전으로 설치해서 활용했고<br>
파이썬이랑 장고 버전은 책과 달리 제멋대로인데,<br>
파이썬의 경우 M1에서 3.7 이하 특정 버전들은 활용하기 매우 번거롭고 귀찮기 때문에 대충 3.8 버전대로 진행했고<br>
그렇다보니 Django 1.7이 파이썬 3.6 이후로는 호환이 안 되어서(HTMLParseError가 남) 이것도 그냥 최신 버전으로 깔았다.<br>
<br>
### TDD(Test-Driven Development)<br>
TDD 즉 테스트 주도 개발이란 간단히 말해 어떤 내용을 개발하기에 앞서 이를 위한 테스트 코드를 먼저 작성하고, 이 내용을 기반으로 개발을 해 나가는 방식을 의미한다.<br>
개발 속도가 느려진다는 단점 & 필요한 기능에 대한 깔끔한 개발을 할 수 있다는 장점이 있다.<br>
<br>
### Chapter 01. 기능 테스트를 이용한 Django 설치<br>
<br>
모든 것을 테스트부터 거치는 TDD 방식에 걸맞게, 책에서는 설치 직후 장고의 runserver 정상 실행 여부부터 테스트할 수 있도록 예시 코드를 제공한다.<br>
해당 코드는 아래와 같으며, 과제를 위한 프로젝트 폴더 안에  functional_tests.py 라는 이름으로 저장한다. (코드 실행 전에 selenium 설치가 필요하다.)<br>

```python
from selenium import webdriver

browser = webdriver.Firefox()
browser.get('http://localhost:8000')

assert 'Django' in browser.title
```
자 그런데 우리는 아직 런서버는커녕 장고 프로젝트를 만들지도 않았다.<br>
그러니까  위의 코드를 실행하면 파이어폭스 창이 뜨면서 '연결할 수 없음'이 떠야 정상...이지만<br>
어째서인지 나의 터미널에는 FileNoeFoundError: [Errno 2] No such file or directory: 'geckodriver'가 뜬다.<br>
뭐임<br>
당황하지 않고 에러메시지를 그대로 쭉 긁어 검색을 돌린 결과...<br>
대충 geckodriver가 있어야 selenium에서 타 브라우저를 자유롭게 쓸 수 있다는 내용인 듯한 스택오버플로우 글들이 좌라락 떴고<br>
뚝딱이처럼 나는 그냥 그들이 시키는 대로 geckodriver를 깔았다.<br>
```commandline
brew install geckodriver
```
간단!<br>
이제 됐겠지<br>
```commandline
selenium.common.exceptions.SessionNotCreatedException:
Message: Expected browser binary location, 
but unable to find binary in default location, no 'moz:firefoxOptions.binary' 
capability provided, and no binary flag set on the command line
```
응 안됐음<br>
이것은 또 무엇이냐... 변함없이 내 친구 스택오버플로우를 찾아서 별 이상한 방법들을 다 시도해 봤으나<br>
오류는 멈추지를 않고<br>
급기야 나는 파폭에 binary 파일이 따로 있는 것인가 받아야 하는 것인가 하는... 고민에 이르렀다.<br>
그런데...<br>
<br>
아... 지킬에 이미지 첨부하는 방법이 너무 번거로워서 쓸 수가 없네<br>
아무튼 대충...<br>
##### 런치패드를 눌러본 짤...
#### 런치패드를 샅샅이 뒤져보는 짤...
### 파이어폭스가 없는 짤...
이런걸 순차적으로 생각해주심 됨. 마지막거는 좀 화질 깨질 때까지 클로즈업한 느낌으로 떠올려주심 좋겠음<br><br>
파이어폭스가 아예 안 깔려있었던 것이다. 바보 아님?<br>
하여튼 개발은 나 바보 아님? 이랑 나 좀 천재인듯 을 반복하는 과정이기 때문에... 오늘치 바보 아님? 은 파이어폭스인 걸로...<br><br>
그래서<br>
환경 : `Mac(M1)`, `Python 3.8.3`,  `Django 4.0.4`,  `Selenium 4.1.3`,  `Firefox` <-NEW!<br><br>
파이어폭스를 받고 났더니 매우 멀쩡히 정상적으로 드디어 '연결할 수 없음'이 떴다!<br>
여전히 이미지 첨부가 귀찮기 때문에 대충... 연결 못한 브라우저 짤을 상상해주시면 됨<br>
물론 셀레늄에서 파이어폭스 대신 다른 브라우저를 써도 된다.(크롬 쓰려면 chromedriver를 받아야 한다는 듯)<br>
나는 정직하게 책을 따라하고 싶었기 때문에 그냥 파이어폭스를 깔고 끝냈다.<br><br>

자 그러면 이제 드디어 본격적으로 장고 프로젝트를 만들 시간이 왔다. 나참 챕터1부터 이렇게 고될 일인지? 물론 그건 다 내가 바보인 탓이지만<br>
아무튼 익숙한 방식으로 대충 장고 프로젝트를 하나 만든다. 여기서는 superlists라는 이름으로 만들었길래 나도 그대로 했다.<br>
```commandline
django-admin startproject superlists
```
여기서 주의할 점 : 책에서는 django-admin.py 를 써서 만들라고 되어있지만 그대로 했다간 이건 더 이상 지원이 되지 않는다는 뭐 그런 비슷한 경고를 직면하게 된다.<br>
경고만 뜨고 플젝생성은 제대로 해주긴 하는데 아무튼 장고에서 바꿔달라고 하니까 .py는 빼고 바꿔주는 게 정신건강에 좋을 듯하다.<br><br>
그 뒤엔 아까 만든 functional_tests.py를 프로젝트 내부 바닥 위치에 옮겨주고(mv 명령어를 쓰시든 그냥 복사붙여넣기 하시든 취향껏 하시라)<br>
우리의 칭구 runserver를 입력한다.
```commandline
python manage.py runserver
```
런서버가 문제없이 진행되어서 127.0.0.1:8000 어쩌구 중지하려거든 컨트롤C를 누르시오 까지 떴다면 이제 다시 아까의 테스트파일을 실행해 본다.<br>
그럼 드디어 익숙한 장고 첫화면이 파이어폭스 화면에 뜬 모습을 보게 된다!<br>
하지만 장고 버전 차이 때문인지 브라우저 타이틀 내용에 Django가 안 들어가서 결국 어설션 에러가 뜬다.<br>
그래서 테스트코드의 마지막 줄 assert 부분 코드를 아래와 같이 바꿔주었더니 잘 되었다.<br>
```python
assert 'successfully' in browser.title
```

이게 이렇게까지 설명할 내용이 아니었던 것 같은데 쓰다보니 사족이 붙어서 구구절절해졌기 때문에 반성하는 마음에 깃 커밋하는 내용은 몽땅 생략하도록 하겠음<br>
자세한 설명이 필요하시면 책을 구매하시거나 구매하세요! 화이팅!<br><br><br>

### Chapter 02. unittest 모듈을 이용한 기능 테스트 확장<br><br>

두 번째 챕터에서에 와서야 비로소 우리가 만들고 있는 게 To-Do 사이트 구축이라는 것을 알게 된다.<br>
만들어두면 제법 쓸모가 있을 아이템이기 때문에 만족스럽다.<br>
이제 필요한 기능이 어떤 것들인지 구상하는 단계에 왔기  때문에 기능 테스트(Functional test, FT==승인 테스트==종단간 테스트)를 이용한 설계에 들어가야 한다.<br>
(이를 통해 유저 관점에서 애플리케이션을 확인하고 이해할 수 있다.)<br>
<br>
여기서 강조된 내용은 FT가 사람이 이해할 수 있는 스토리(주로 유저단의 흐름을 따라가는 User story)를 가지고 있어야 한다는 것이다.<br>
즉 프로그래머가 아닌 사람(기획자, QC담당자 등)이 보아도 한 눈에 이해할 수 있도록 주석 등으로 깔끔히 정리가 되어야 한다.<br>
FT만으로도 요구사항과 특징을 논의할 수 있어야 한다는데, TDD를 통해 개발 시간이 길어질 것을 생각하면 이런 부분에서 문서 단계를 줄이는 게 확실히 효율적일 것 같다.<br>
<br>
다시 우리가 만들던 To-Do 사이트로 돌아와서...이 챕터에서는 애자일(Agile) 개발 방식에서 진행하듯이 최소 기능 애플리케이션을 구축해 테스트 하는 것을 쬐끔 맛보기할 수 있다.<br>
먼저 사용자가 작업을 입력하고 이를 저장하는 기능을 구현하기 위한 준비에 들어간다.<br>
평소 같으면 바로 모델 설계에 들어갔겠지만 TDD이므로 다른 모든 작업에 앞서 챕터1에서 만들어둔 functional_tets.py 파일에 테스트용 스토리를 추가한다.<br>
```python
from selenium import webdriver

 browser = webdriver.Firefox()

 # 유저가 웹사이트를 확인한다
 browser.get('http://localhost:8000')

 # 웹 페이지 타이틀과 헤더가 'To-Do'를 표시하고 있다
 assert 'To-Do' in browser.title, "Browser title was " + browser.title

 # 유저가 작업을 추가하기로 한다

 # 할일 내용을 텍스트 상자에 입력한다 (예: 공작깃털 사기)
 # 엔터키를 치면 페이지가 갱신되고 작업 목록에 해당 할일 내용이
 # "1: 공작깃털 사기" 형식으로 추가된다

 # 추가 아이템을 입력할 수 있는 여분의 텍스트 상자가 존재한다
 # 다른 할일을 입력한다(예: "공작깃털을 이용해서 그물 만들기")

 # 페이지가 다시 갱신되고, 두 개 아이템이 목록에 보인다
 # 유저는 사이트가 입력한 목록을 저장하고 있는지 궁금하다
 # 사이트는 유저를 위한 특정 URL을 생성해준다
 # 이때 URL에 대한 설명도 함께 제공된다

 # 해당 URL에 접속하면 유저가 만든 작업 목록이 그대로 있는 것을 확인할 수 있다

 # 이용을 마친다

 browser.quit()

```
추가가 완료되었으면 runserver를 통해 서버를 시작한 뒤 테스트를 실행한다.<br>
위의 내용을 보면 assertion이 타이틀에서 'To-Do'를 찾도록 수정되었는데, 현재 해당 내용은 개발되어 있지 않으므로 오류가 날 것이다.<br>
여기서는 오류 메시지를 좀 더 명확히 표시하기 위해  실제 표시된 타이틀을 함께 출력하도록 추가했다.<br><br>
오류 내용은 아래와 같다.<br>
```commandline
AssertionError: Browser title was The install worked successfully! Congratulations!
```

테스트가 끝난 브라우저 창을 닫아주는 등 소소한 내용을 추가해줄 때 unittest 모듈을 사용하면 편하다.<br>
테스트 코드를 아래와 같이 다시 수정한다.<br>
```python
from selenium import webdriver
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
        self.fail('Finish the test!')   # 강제로 테스트 실패 발생시키기

        # 유저가 작업을 추가하기로 한다

        # 할일 내용을 텍스트 상자에 입력한다 (예: 공작깃털 사기)
        # 엔터키를 치면 페이지가 갱신되고 작업 목록에 해당 할일 내용이
        # "1: 공작깃털 사기" 형식으로 추가된다

        # 추가 아이템을 입력할 수 있는 여분의 텍스트 상자가 존재한다
        # 다른 할일을 입력한다(예: "공작깃털을 이용해서 그물 만들기")

        # 페이지가 다시 갱신되고, 두 개 아이템이 목록에 보인다
        # 유저는 사이트가 입력한 목록을 저장하고 있는지 궁금하다
        # 사이트는 유저를 위한 특정 URL을 생성해준다
        # 이때 URL에 대한 설명도 함께 제공된다

        # 해당 URL에 접속하면 유저가 만든 작업 목록이 그대로 있는 것을 확인할 수 있다

        # 이용을 마친다

        
# 해당 스크립트가 커맨드라인을 통해 실행되었을 경우에만 unittest 가동
if __name__ == '__main__':
    unittest.main(warnings='ignore')
```
이제 실행하면 아래와 같이 실패 메시지가 뜬다. 만세!<br>
```commandline
F
======================================================================
FAIL: test_can_start_a_list_and_retrieve_it_later (__main__.NewVisitorTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "functional_test.py", line 21, in test_can_start_a_list_and_retrieve_it_later
    self.assertIn('To-Do', self.browser.title)  # 테스트용 어설션을 위해 assertIn 사용
AssertionError: 'To-Do' not found in 'The install worked successfully! Congratulations!'

----------------------------------------------------------------------
Ran 1 test in 2.095s

FAILED (failures=1)
```
<br><br>

#### 유용한 TDD 개념
* 사용자 스토리(User story) : 사용자 관점에서 어떻게 애플리케이션이 동작해야 하는지 기술한 것. 기능 테스트 구조화를 위해 사용
* 예측된 실패(Expected failure) : 의도적으로 구현한 테스트 실패
