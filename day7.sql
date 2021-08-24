복습

--10년 1월 1일 기준 근속년수가 10 초과인 직원의 이름
SELECT EMP_NAME, TRUNC(MONTHS_BETWEEN('10/01/01' , HIRE_DATE)/12) AS 근속
FROM EMPLOYEE
WHERE TRUNC(MONTHS_BETWEEN('10/01/01' , HIRE_DATE)/12) > 10;

--사번이 100인 직원의 이름과 급여 출력해보자
SELECT EMP_NAME, SALARY 
FROM EMPLOYEE
WHERE EMP_ID = TO_CHAR(100); //명시 형변환

-- 이름과 입사일을 별칭으로 출력하되 입사일은 0000-00-00 형식으로 출력하기, 단 J7 직군만 출력한다.
SELECT EMP_NAME AS 이름, TO_CHAR(HIRE_DATE, 'YYYY-MM-DD') AS 입사일
FROM EMPLOYEE
WHERE JOB_ID = 'J7';

-- JOB ID가 J1, J2인 사원의 이름, 기본 입사일, 상세 입사일을 별칭으로 출력한다, 단 상세 입사일을 0000/00/00 00:00:00D으로 출력한다.
SELECT EMP_NAME AS 이름, HIRE_DATE AS 기본입사일, TO_CHAR(HIRE_DATE, 'YYYY/MM/DD HH24:MI:SS') AS 상세입사일
FROM EMPLOYEE
WHERE JOB_ID IN('J1','J2');
