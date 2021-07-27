--  RDBMS

중복되는 값을 따로 빼어 새로운 테이블로 만들게 되면 유지보수에 굉장히 편함.
하지만 테이블을 따로따로 분리해서 보게되면 데이터를 보기가 굉장히 어려움

## 따라서 "JOIN" 을 해줘야 한다.

토픽테이블을 왼쪽에 두고 각 topic.author_id = author.id; 열을 기준으로 테이블을 조인해줌.
SELECT * FROM topic LEFT JOIN author ON topic.author_id = author.id;


조인한 테이블에 같은 이름의 열이 있으면 모호함이라고 출력함.
SELECT id,title,description, created, name,profile FROM topic LEFT JOIN author ON topic.author_id = author.id;

코드를 아래와 같이 작성하여 기존 id 열을 > topic_id 열로 변경
SELECT topic.id AS topic_id,title,description, created, name,profile FROM topic LEFT JOIN author ON topic.author_id = author.id;

하나의 테이블만 수정해주더라도 조인된 모든 것들이 다 변경됨.,. 관계형데이터를 진짜 관계형 데이터로 만들어주는 것이 바로 JOIN
