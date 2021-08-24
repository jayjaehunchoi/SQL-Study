
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

-- 90/04/01 입사자를 출력하는 두가지 방법
SELECT EMP_NAME, HIRE_DATE
FROM EMPLOYEE
WHERE TO_CHAR(HIRE_DATE, 'YYMMDD') = '900401';

SELECT EMP_NAME, HIRE_DATE
FROM EMPLOYEE
WHERE HIRE_DATE = TO_DATE('900401 133030','YYMMDD HH24MISS');

-- ORACLE의 세기

SELECT '2009/10/14' AS 현재,   '95/10/27' AS 입력,
TO_CHAR(TO_DATE('95/10/27','YY/MM/DD'),'YYYY/MM/DD') AS YY형식1, //YY 형식으로 입력됐기때문에 현재 세기로 기입된다. 2095
TO_CHAR(TO_DATE('95/10/27','YY/MM/DD'),'RRRR/MM/DD') AS YY형식2,
TO_CHAR(TO_DATE('95/10/27','RR/MM/DD'),'YYYY/MM/DD') AS RR형식1,//RR 형식으로 입력됐기 때문에 현재를 50년 아래로 판단하여 아래 세기로 기입한다 1995
TO_CHAR(TO_DATE('95/10/27','RR/MM/DD'),'RRRR/MM/DD') AS RR형식2
FROM DUAL;

-- 기타 단일 행 함수 = DECODE
-- SELECT 구문으로 IF-ELSE 논리를 제한적으로 구현한 오라클 함수
DECODE(expr,search1,result1[, searchN, resultN,...][, default])
expr : 대상 컬럼 혹은 문자열
search1 : expr과 비교하려는 값
result1 : IF expr = search1 인 경우 반환
default : expr과 search1 이 일치하지 않은 경우의 기본 리턴값, default 지정하지 않고 expr 과 search1이 일치하지 않으면 NULL값 리턴

