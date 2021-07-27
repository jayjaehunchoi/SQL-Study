-- CREATE

-- opentutorials라는 데이터베이스 생성
CREATE DATABASE opentutorials;

-- opentutorials 데이터베이스 사용
USE opentutorials;

-- opentutorials에 테이블 생성
CREATE TABLE topic(
id INT NOT NULL AUTO_INCREMENT, -- id칼럼, 정수형, 빈칸 허용 안됨, 자동 증가 
title VARCHAR(100) NOT NULL, -- title 칼럼, 문자형(변동가능), 빈칸 허용 안됨
description TEXT NULL, -- description 칼럼, 텍스트 꽤 김, 빈칸 ok
created DATETIME NOT NULL, -- created 칼럼, 시간, 빈칸 허용 안됨
author VARCHAR(30) NULL, -- author 칼럼, 문자형, 빈칸 ok
profile VARCHAR(100) NULL, -- profile 칼럼 , 문자형, 빈칸 ok
PRIMARY KEY id));  -- 프라이머리 키, 이걸로 구분할 수 있음 (쇼핑몰의 아이디 느낌)

-- topic table에 데이터 넣기
INSERT INTO topic (title, description, created, author, profile) VALUES('My SQL','My SQL is...', NOW(), 'egoing', 'developer); -- id는 자동증가이기 때문에 안넣음.


-- READ

-- 테이블 읽기
SELECT * FROM topic; -- topic 테이블 전체 읽기.
SELECT id, title, created FROM topic; -- topic 테이블에서 id title created 칼럼 읽기.
SELECT id, title, created, author FROM topic WHERE author = 'egoing'; -- topic 테이블에서 id title created 칼럼 중 author가 egoing인 사람 읽기.
SELECT id, title, created, author FROM topic WHERE author ORDER BY id DESC; -- topic 테이블에서 id title created 칼럼 중 author가 egoing인 사람 id 역순으로 읽기.
SELECT id, title, created, author FROM topic WHERE author ORDER BY id DESC LIMIT 2; -- topic 테이블에서 id title created 칼럼 중 author가 egoing인 사람 id 역순으로 2개 읽기.

-- 정보 보기
DESC topic; -- show topic description;


--UPDATE

UPDATE topic SET description = 'MY SQL is,,,' WHERE id = 1; -- id가 1인 행의 description 칼럼을 "" 내부 값으로 변경.

--DELETE
DELETE FROM topic WHERE id = 1; -- id 1번 행 삭제

-- UPDATE와 DELETE WHERE 쓰지 않으면 정말 큰 재앙이 온다............. 꼭 기억.
