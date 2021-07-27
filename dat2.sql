--  RDBMS
중복되는 값을 따로 빼어 새로운 테이블로 만들게 되면 유지보수에 굉장히 편함.

토픽테이블을 왼쪽에 두고 각 topic.author_id = author.id; 열을 기준으로 테이블을 조인해줌.
SELECT * FROM topic LEFT JOIN author ON topic.author_id = author.id;
