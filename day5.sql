SELECT ENAME, EMP.DEPTNO, DNAME
FROM EMP, DEPT; -- ENTITY(테이블을 객체화한 단어);

SELECT ENAME, E.DEPTNO, DNAME
FROM EMP E, DEPT D;

ROWID, ROWNUM
-> 테이블 생성 후 데이터를 ROW 단위로 입력할 때 자동으로 생성되는 컬럼의 속성값

데이터 무결성 제약조건 확인
SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS;


불러와서 생성하는경우도 있음.
CREATE TABLE TEST01(MYNAME, MYSAL)
  AS
  SELECT ENAME, SAL FROM EMP;

구조만 가져오기
CREATE TABLE TEST02
AS
SELECT * FROM EMP
WHERE 1 = 0;

TO_CHAR(HIREDATE, 'YYYY-DD-MM') > 날짜 형식


문자열 LIKE % - 모든 , _ 한글자

'ABCD' LIKE 'A%' - A로 시작하는 모든 글자

EX) 
SELECT ENAME FROM EMP WHERE ENAME LIKE '%S'; 끝자리가 S
SELECT ENAME FROM EMP WHERE ENAME LIKE '%T%'; 어디든 T만 나오면
SELECT ENAME FROM EMP WHERE ENAME LIKE '%L%L%'; L 두개

SELECT last_name 
    FROM employees
    WHERE last_name LIKE '%A\_B%' ESCAPE '\' >> ESCAPE를 줘서 문자열 내에 _나 %가 있어도 \로 구분해줄 수 있다
    ORDER BY last_name;
    
SELECT ENAME, SAL FROM EMP ORDER BY ENAME, SAL DESC; ENAME 오름차순, 그중에서 동일한 스펠이면 SAL로 내림차순

숫자함수, 문자함수, 날짜함수 > TO_NUMBER(), TO_CHAR(), TO_DATE()
집계함수 (분석함수) > GROUP BY 

개수, 합, 평균, 최대 ,최소 ,중간값 (집계함수)
SELECT COUNT(SAL), SUM(SAL), AVG(SAL), MAX(SAL), MIN(SAL), MEDIAN(SAL) FROM EMP;

1. GROUP BY 특징 
- GROUP BY 다음에는 데이터를 구분짓기 위한 표현식으로 해당 테이블의 컬럼 명 혹은 변수값이 올 수 있음 하지만 그룹함수를 사용한 형태는 올 수 없음 EX) GROUP BY AVG(SAL)
- SELECT ~ LIST 에는 GROUP BY 문에 명시된 표현식과 그 외 그룹함수를 사용한 표현식만 올 수 있다.
- 출력된 결과를 정렬하기 위해 ORDER BY 문을 사용한다, 단 ORDER BY 문 다음에는 SELECT ~ LIST에서 명시된 컬럼 또는 표현식과 컬럼의 별칭, 컬럼 번호등만 사용된다.

HAVING 
GROUP BY 로 집계된 데이터에 조건을 줄 때 사용되는 쿼리문
GROUP BY 로 걸러진 조건을 다시 필터링해줌
제 2의 조건문, 조건문에서 그룹함수 사용 가능

HAVING 문 다음에는 SELECT ~ LIST에서 사용한 칼럼과 그룹함수를 사용한 컬럼에 대해서만 조건을 사용할 수 있다.
SELECT JOB, SUM(SAL) FROM EMP GROUP BY JOB HAVING SUM(SAL) >= 3500 ORDER BY 2 DESC;

ROLLUP으로 총합을 낼 수도 있음
 SELECT DEPTNO, SUM(SAL) FROM EMP GROUP BY ROLLUP(DEPTNO) HAVING SUM(SAL) >= 8000;
 
 
