SQL의 분류

-- DML 
데이터 조작 언어 SELECT UPDATE DELETE INSERT 등

-- DDL
CREATE DROP ALTER 등 데이터 정의 언어

--DCL
사용자 제어 언어

-- 언어
SHOW DATABASES; - 데이터 베이스 보여줘
USE databasename - 데이터베이스 사용하겠어
SHOW TABLES - 선택한 데이터 베이스의 테이블을 보여줘
DESC databasename - 데이터베이스 요약해줘(무슨 열 있는지, 열정보는 어떤지)

SELECT * FROM city; - 시티 테이블 보여줌 , *은 모든 열 > *위치에 열이름 넣으면 해당 열 데이터만 보여줌
SELECT * FROM city WHERE population > 8000000 ; - 인구가 800만 초과하는 행들만 보여줘

AND - 모든 조건이 참일때 ex) SELECT * FROM city WHERE population < 8000000 AND Population > 7000000 ;
BETWEEN AND - 조건과 조건 사이 ex) SELECT * FROM city WHERE Population BETWEEN 7000000 AND 8000000;
IN - 해당 행만 보여줄 때 ex) SELECT * FROM city WHERE Name IN('Seoul', 'New York', 'Tokyo');
LIKE - 문자열 검색, 한글자 매칭은 _ , 여러글자 % ex) SELECT * FROM city WHERE CountryCode LIKE 'KO_'

[SUB QUERY] - 특정 쿼리 내에 또다른 쿼리가 있을 때

SELECT * FROM city 
WHERE CountryCode = (	SELECT CountryCode
                      FROM city
                      WHERE Name = 'Seoul' );
>> () 내부 ,city 테이블의 컨트리코드열만 가져오는데 그 중 이름이 Seoul인 행의 컨트리코드를 가져와달라
>> () 외부, ciry 테이블의 컨트리코드 열 중 행이 KOR 인 애들을 가져와라. 

SELECT * FROM city 
WHERE Population > 	ANY	 (	SELECT Population
                    FROM city
                    WHERE District = 'New York' );
ANY -> ()내부의 어떤 값이든 만족할 때

SELECT * FROM city 
WHERE Population > 	ALL	 (	SELECT Population
                            FROM city
                            WHERE District = 'New York' );
ALL -> 모든 값을만족하는 친구를 끌어와라(제일 인구수가 높은 애보다 높은 애들 출력)

ORDER BY - SELECT * FROM city ORDER BY Population DESC; 내림차순, 오름차순으로 보여주는 것 
DISTINCT - 중복을 제외하고 보여줌. SELECT DISTINCT CountryCode FROM city;
LIMIT - 행 개수 제한 하고 보여줌 SELECT * FROM city ORDER BY Population DESC LIMIT 10;
GROUP BY - 그룹으로 묶어주는 역할 주로 집계함수와 함께 사용됨
ex) CountryCode와 Max population으로 그룹이뤄짐, 그룹바이 함수쓰였을 때 조건문은 HAVING으로 선언한다.
SELECT CountryCode, MAX(Population)
FROM city
GROUP BY CountryCode 
HAVING MAX(Population) > 8000000;

집계함수 - AVG() 평균/ MIN() 최소/ MAX() 최대/ COUNT() 개수/ COUNT(DISTINCT) 중복제외 개수/ STDEV() 표준편차/ VARIANCE() 분산
SELECT CountryCode,AVG(Population) AS 'Average' --AS 칼럼명
FROM city

WITH ROLLUP - 
SELECT CountryCode, Name, MAX(Population)
FROM city
GROUP BY CountryCode, Name WITH ROLLUP;
