
1. datetime
SELECT ENAME, EXTRACT(YEAR FROM (SYSDATE - hiredate) YEAR TO MONTH)
       || ' years '
       || EXTRACT(MONTH FROM (SYSDATE - hiredate) YEAR TO MONTH)
       || ' months'  "Interval"
  FROM emp;
  
  문제 풀이.
  
--1. 사원테이블에서 부서별 최대 월급을 출력하라.
SELECT DEPTNO, MAX(SAL) 
FROM EMP 
GROUP BY DEPTNO;

--2. 사원테이블에서 직위별 최소 월급을 구하되 직위가 
-- CLERK인 것만 출력하라.
 SELECT JOB, MIN(SAL) 
 FROM EMP 
 WHERE JOB = 'CLERK' 
 GROUP BY JOB;

--3. 커미션이 책정된 사원은 모두 몇 명인가?
SELECT COUNT(COMM) 
FROM EMP 
WHERE COMM IS NOT NULL;

--4. 직위가 'SALESMAN'이고 월급이 1000이상인 사원의
-- 이름과 월급을 출력하라.
SELECT ENAME, SAL 
FROM EMP 
WHERE JOB = 'SALESMAN' 
AND SAL >= 1000;

--5. 부서별 평균월급을 출력하되, 평균월급이 2000보다
-- 큰 부서의 부서번호와 평균월급을 출력하라.
SELECT DEPTNO, AVG(SAL) 
FROM EMP 
GROUP BY DEPTNO 
HAVING AVG(SAL) >= 2000;


--6. 직위가 MANAGER인 사원을 뽑는데 월급이 높은 사람
-- 순으로 이름, 직위, 월급을 출력하라.
SELECT ENAME, JOB, SAL 
FROM EMP 
WHERE JOB = MANAGER 
ORDER BY SAL DESC;

--7. 각 직위별로 총월급을 출력하되 월급이 낮은 순으로-- 출력하라.
SELECT JOB, SUM(SAL) 
FROM EMP 
GROUP BY JOB 
ORDER BY SUM(SAL);


--8. 직위별 총월급을 출력하되, 직위가 'MANAGER'인
-- 사원들은 제외하라. 그리고 그 총월급이 5000보다 
-- 큰 직위와 총월급만 출력하라.

SELECT JOB, SUM(SAL) 
FROM EMP 
WHERE JOB != 'MANAGER' 
GROUP BY JOB 
HAVING SUM(SAL) > 5000;

--9. 직위별 최대월급을 출력하되, 직위가 'CLERK'인 
-- 사원들은 제외하라. 그리고 그 최대월급이 2000 이상인 직위와 최대월급을 최대 월급이 높은 순으로 정렬하여 출력하라.
SELECT JOB, SUM(SAL) 
FROM EMP 
WHERE NOT JOB = 'CLERK' 
GROUP BY JOB  
HAVING SUM(SAL) >= 2000 
ORDER BY SUM(SAL) DESC;


--10.부서별 총월급을 구하되 30번부서를 제외하고, 그 총월급이 8000달러 이상인 부서만 나오게하고, 총월급이 높은 순으로 출력하라.

SELECT DEPTNO, SUM(SAL) 
FROM EMP 
WHERE NOT DEPTNO = 30 
GROUP BY DEPTNO 
HAVING SUM(SAL) >= 8000 
ORDER BY SUM(SAL) DESC;

--11. 부서별 평균월급을 구하되 커미션이 책정된 사원만 가져오고, 그 평균월급이 1000달러 이상인 부서만 나오게하고, 평균월급이 높은 순으로 출력하라
 SELECT DEPTNO, AVG(SAL) 
 FROM EMP 
 WHERE COMM IS NOT NULL 
 GROUP BY DEPTNO 
 HAVING AVG(SAL) >= 1000 
 ORDER BY AVG(SAL) DESC;
 
 IN 연산자 (OR 간소화)
 SELECT EMPNO, ENAME 
 FROM EMP 
 WHERE EMPNO IN(7499,7521,7654);
 
 BETWEEN AND(AND 간소화)
 SELECT EMPNO, ENAME, SAL
  FROM EMP
  WHERE SAL BETWEEN 1500 AND 3000;
  
  
 - 찾는 문자열이 지정된 위치부터 지정한 회수만큼 나타난 시작 위치를 반환하는 함수
 INSTR(string, substring, [position], [occurrence])
 
position : 어디서 부터 찾을지를 결정하는 시작위치 (default 1)
position > 0 시작부터 끝방향, position < 0 끝부터 시작방향
position 으로부터 occurence번째 substring의 위치

SELECT 'SG_AHN@ABC.COM', INSTR('SG_AHN@ABC.COM','B',-1,1) FROM DUAL;

왼쪽 채우기(RPAD는 오른쪽채우기)
SELECT ENAME, LPAD(ENAME,20,'*') RES
FROM EMP;

TRIM 공백 제거
SELECT '  ABC  ', TRIM('  ABC  '), RTRIM('  ABC  '), LTRIM('  ABC  ')
FROM DUAL;

SELECT TRIM('A' FROM 'AATECHAA') 
FROM DUAL;

TRIM 조건 제거 (한글자씩 TRUE / FALSE 판별 > 왼쪽부터 진행하다 FALSE를 만나면 STOP, RTRIM은 반대)
SELECT LTRIM('123TECH123123', '123') FROM DUAL;
SELECT TRIM(LEADING FROM '  TECH  ') FROM DUAL; -- LTRIM임
SELECT TRIM(TRAILING '1' FROM 'TECH1111') FROM DUAL; --RTRIM임
