
-- 여러가지 JOIN
SELECT EMP_NAME, DEPT_NAME
FROM EMPLOYEE
JOIN JOB USING(JOB_ID)
JOIN DEPARTMENT USING(DEPT_ID)
JOIN LOCATION ON(LOC_ID = LOCATION_ID)
WHERE JOB_TITLE = '대리'
AND LOC_DESCRIBE LIKE '아시아%';

SELECT EMP_NAME, LOC_DESCRIBE, DEPT_NAME
FROM EMPLOYEE
JOIN DEPARTMENT USING(DEPT_ID)
JOIN LOCATION ON(LOC_ID = LOCATION_ID);

-- SET OPERATOR 두개 이상의 쿼리 결과를 하나로 결합하는 연산자, SELECT절에 기술하는 칼럼 개수와 데이터 타입은 모든 쿼리에서 동일해야 함
UNION : 양쪽 쿼리 결과를 모두 포함 (중복된 결과는 1번만 표현)
UNION ALL : 양쪽 쿼리 결과를 모두 포함 (중복 결과도 모두 표현)
INTERSECT : 양쪽 쿼리 결과에 모두 포함되는 행만 표현
MINUS : 쿼리 1, 2가 존재할 경우 쿼리 1에만 포함되는 행만 표현

-- 변동 있었던 사람의 데이터가 쌓인다.
SELECT EMP_ID, ROLE_NAME
FROM EMPLOYEE_ROLE
UNION SELECT EMP_ID, ROLE_NAME FROM ROLE_HISTORY;

-- 직무 변동 기록 없는 직원들
SELECT EMP_ID, ROLE_NAME
FROM EMPLOYEE_ROLE
MINUS
SELECT EMP_ID, ROLE_NAME
FROM ROLE_HISTORY;

-- 컬럼 개수가 맞지 않은 경우
SELECT EMP_NAME, JOB_ID, HIRE_DATE
FROM EMPLOYEE
WHERE DEPT_ID = '20'
UNION
SELECT DEPT_NAME, DEPT_ID, NULL
FROM DEPARTMENT
WHERE DEPT_ID = '20';

-- 사원 번호, 사원 이름, 141번이 관리자이고 그를 관리자로 둔 사람을 직원으로 둬라
SELECT EMP_ID, EMP_NAME, '관리자' AS 구분
FROM EMPLOYEE
WHERE EMP_ID = '141'
AND DEPT_ID = '50'
UNION
SELECT EMP_ID,EMP_NAME,'직원' AS 구분
FROM EMPLOYEE
WHERE MGR_ID = '141'
AND DEPT_ID = '50';

-- SET을 조인으로
SELECT EMP_ID, ROLE_NAME
FROM EMPLOYEE_ROLE
INTERSECT
SELECT EMP_ID, ROLE_NAME
FROM ROLE_HISTORY;
  
SELECT EMP_ID, ROLE_NAME
FROM EMPLOYEE_ROLE
JOIN ROLE_HISTORY
USING (EMP_ID, ROLE_NAME);

SELECT EMP_NAME, '사원' AS 직급
FROM EMPLOYEE
JOIN JOB USING(JOB_ID)
WHERE JOB_TITLE = '사원'
UNION
SELECT EMP_NAME, '대리' AS 직급
FROM EMPLOYEE
JOIN JOB USING(JOB_ID)
WHERE JOB_TITLE = '대리'
ORDER BY 2,1;

-- WHERE로 이중 조건
SELECT EMP_NAME, JOB_TITLE, SALARY
FROM EMPLOYEE
LEFT JOIN JOB USING(JOB_ID)
WHERE (JOB_ID, SALARY) IN
(SELECT JOB_ID,
TRUNC (AVG(SALARY), -5)
FROM EMPLOYEE
GROUP BY JOB_ID)
ORDER BY JOB_ID;

-- SUBQUERY CORRELATED SUBQUERY TBD
