
1. 자바의 식별자 생성 규칙과 동일 
2. 명령구분 대소문자 구별 x
3. VALUE 는 대소문자 명확하게 구분

- SELECT ~ FROM 명령문(READ)

SELECT
FROM
WHERE
HAVING
GROUP BY
ORDER BY

1. SELECT 컬럼명[*], [별칭] FROM 테이블 - 테이블 READ

2. DESC TABLENAME; - 테이블의 구조
숫자 : NUMBER(자리수, 소수이하)
문자 : CHAR()
문자열 : VARCHAR 2000 , VARCHAR2 4000
날짜 : DATE
시간 : TIME

3. 컬럼 나열하는 곳에 별칭
SELECT 컬럼명 AS 별칭 FROM ~ 
SELECT 컬럼명 AS "별   칭" FROM ~

4. 연결 문자열
SELECT ENAME||님 AS "사원의 이름" FROM EMP;

5. 조건문
SELECT * FROM EMP WHERE NOT (A = "Sick);
SELECT * FROM EMP WHERE A = 'Sick' OR B<> = 'SFSF';

6. 개수
SELECT COUNT (*)
FROM EMP;

7. 중복, NULL 값 제외
SELECT COUNT(DISTINCT NAME)
FROM ANIMAL_INS
WHERE NAME IS NOT NULL;

8. GRUOP BY 활용
SELECT ANIMAL_TYPE, COUNT(ANIMAL_TYPE) 
FROM ANIMAL_INS 
GROUP BY ANIMAL_TYPE 
ORDER BY ANIMAL_TYPE;

9. 사칙연산
SELECT ENAME,SAL, SAL*12 
AS 연봉 
FROM EMP;

만약 NULL 값이면 , NVL 을 이용함 NVL(COMM, SAL) < COMM 중에 NULL 값이 있으면 SAL로 처리해주는 열 만듦
SELECT ENAME,SAL AS 봉급 
,COMM, NVL(COMM,SAL), 
SAL*12 - NVL(COMM,SAL) 
AS 연봉 
FROM EMP;

형변환
SELECT ENAME,
NVL(TO_CHAR(MGR),'없음') 
AS "매니저 사번" 
FROM EMP;

 SELECT ENAME, SAL, COMM, 
 NVL2(COMM,SAL*12-COMM, SAL*12) -- NVL2(COMM이 NULL 이 아니면 , 여기 출력, NULL이면 여기 출력)  
 FROM EMP;
 
동명 수 찾기
SELECT NAME, COUNT(NAME) 
FROM ANIMAL_INS 
GROUP BY NAME -- 이름으로 묶었는데
HAVING COUNT(NAME) > 1 -- 1이상이다
ORDER BY NAME; -- 이름순 출력
