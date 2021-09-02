-- 문제 풀이 프로그래머스 입양시각 구하기(2)
SELECT A.HOUR, NVL(B.COUNT,0) AS COUNT
FROM (SELECT LEVEL-1 AS HOUR
     FROM DUAL
     CONNECT BY LEVEL <= 24)A
LEFT JOIN (SELECT TO_CHAR(DATETIME,'HH24') AS HOUR, COUNT(ANIMAL_ID) AS COUNT
          FROM ANIMAL_OUTS
          GROUP BY TO_CHAR(DATETIME,'HH24')) B
ON(A.HOUR = B.HOUR)
ORDER BY A.HOUR;

-- 없어진 기록찾기
SELECT O.ANIMAL_ID, O.NAME
FROM ANIMAL_OUTS O
LEFT JOIN ANIMAL_INS I
ON O.ANIMAL_ID = I.ANIMAL_ID
WHERE I.ANIMAL_TYPE IS NULL
ORDER BY ANIMAL_ID;

-- 있었는데요 없었습니다
SELECT O.ANIMAL_ID, O.NAME
FROM ANIMAL_INS I
JOIN ANIMAL_OUTS O
ON I.ANIMAL_ID = O.ANIMAL_ID
WHERE I.DATETIME  > O.DATETIME
ORDER BY I.DATETIME;


-- 테이블 수정 - 이름변경
CREATE TABLE TB_EXAM(
COL1 CHAR(2) PRIMARY KEY,
ENAME VARCHAR2(20),
FOREIGN KEY (COL1) REFERENCES EMPLOYEE);

-- 컬럼 이름을 조회하자
SELECT COLUMN_NAME
FROM USER_TAB_COLS
WHERE TABLE_NAME = 'TB_EXAM';

-- 제약조건의 현황을 조회해보자
SELECT CONSTRAINT_NAME AS 이름,
CONSTRAINT_TYPE AS 유형,
COLUMN_NAME AS 컬럼,
R_CONSTRAINT_NAME AS 참조,
DELETE_RULE AS 삭제규칙
FROM USER_CONSTRAINTS
JOIN USER_CONS_COLUMNS
USING (CONSTRAINT_NAME, TABLE_NAME)
WHERE TABLE_NAME = 'TB_EXAM';


-- 컬럼 이름 변경
ALTER TABLE TB_EXAM
RENAME COLUMN COL1 TO EMPID;


-- 제약조건 이름 변경
ALTER TABLE TB_EXAM
RENAME CONSTRAINT SYS_C007158 TO PK_EID;

ALTER TABLE TB_EXAM
RENAME CONSTRAINT SYS_C007159 TO FK_EID;

-- 테이블 이름 변경
ALTER TABLE TB_EXAM
RENAME TO TB_SAMPLE;

RENAME TB_EXAM TO TB_SAMPLE;

-- 테이블 삭제
DROP TABLE table_name [CASCADE CONSTRAINTS];
- 포함된 데이터 및 테이블과 관련된 데이터 딕셔너리 정보까지 모두 삭제
- 삭제 작업은 복구할 수 없다.
- CASCADE CONSTRAINTS : 삭제 대상 테이블의 PK 또는 U 제약조건을 참조하는 다른 제약 조건을 삭제하는 옵션,
  참조중인 제약조건이 있는 경우 옵션이 미사용시 삭제할 수 없다. (FOREIGN KEY로 참조되어있는 상태에서 DROP 하려면 삭제 안됨)

CREATE TABLE MY_DEPT(
DID CHAR(2) PRIMARY KEY,
DNAME VARCHAR2(10));


CREATE TABLE MY_EMP02(
COL1 CHAR(3) PRIMARY KEY,
ENAME VARCHAR2(20),
DID CHAR(2) REFERENCES MY_DEPT);

DROP TABLE MY_DEPT CASCADE CONSTRAINTS;
DROP TABLE MY_EMP02;

INSERT INTO MY_DEPT VALUES(40,'40');
SELECT * FROM MY_DEPT;
SELECT * FROM MY_EMP02;

-- 컬럼삭제
CREATE TABLE TB1(
PK NUMBER PRIMARY KEY,
FK NUMBER REFERENCES TB1,
COL1 NUMBER,
CHECK(PK > 0 AND COL1 > 0));

ALTER TABLE TB1
DROP (PK) CASCADE CONSTRAINTS; -- cascade 로 제약조건 삭제
ALTER TABLE TB1
DROP (COL1) CASCADE CONSTRAINTS;

-- VIEW : 다른 테이블이나 뷰에 포함된 데이터의 맞춤 표현
             STORED QUERY, VIRTUAL TABLE로 간주되는 데이터베이스 객체이다.
             하나 이상의 테이블/ 뷰에 포함된 데이터 부분 집합을 나타내는 논리적인 객체
             자체적으로 데이터를 포함하지 않는다.
             베이스 테이블에 있는 데이터를 조건이나 또는 조인 등을 이용해서 참조하는 형식
-- 사용목적 및 장점 
Restricted data access : 뷰에 접근하는 사용자는 미리 정의된 결과만 볼 수 있다.(데이터 보호)
Hide data complexity : 여러 테이블을 조인하게 되면 복잡한 sql을 숨길 수 있다.
Simplify statement for the user : sql 구문을 몰라도 간단한 select 구문만으로도 원하는 결과를 조회할 수 있다
 
Present the data in a different perspective : 뷰에 포함되는 컬럼은 참조 대상 테이블에 영향을 주지 않고 다른 이름으로 참조 가능하다

Isolate applications from changes in definitions of base tables : 베이스 테이블에 포함된 여러개의 컬럼 중 
일부만 사용하도록 뷰를 생성할 경우 뷰가 참조 되지 않는 나머지 컬럼이 변경되어도 뷰를 사용하는 다른 프로그램이 영향을 받지 않음

Save complex queries : 자주 사용하는 복잡한 sql문을 뷰 형태로 저장하면 반복적으로 사용할 수 있다.

-- VIEW 생성 구문
CREATE [OR REPLACE][FORCE | NOFORCE] VIEW view_name [(alias[,alias,,,]]
AS subquery
[WITH CHECK OPTION [CONSTRAINT constraint_name]]
[WITH READ ONLY [CONSTRAINT constraint_name]]

-- 구문 설명
CREATE [OR REPLACE] : 지정한 뷰가 없으면 새로 생성, 동일한 뷰가 존재하면 수정
[FORCE | NOFORCE] : 원본 테이블이 존재하지 않아도 뷰 생성 가능 | 존재하는 경우에만 뷰 생성 가능
alias : 뷰에서 사용할 이름
subquery : 뷰에서 표현하는 데이터를 생성하는 SELECT 구문
제약 조건 :  
WITH CHECK OPTION :  뷰를 통해 접근 간으한 데이터베이스에 대해서만 DML 작업을 허용
WITH READ ONLY : 뷰를 통해 DML 작업 허용 X

-- 사원 테이블에서 부서번호가 90번 데이터를 가진 V_EMP인 VIEW 생성
CREATE [OR REPLACE] VIEW V_EMP -- [OR REPLACE] 써도되고 안써도됨(수정할 땐 꼭 써야됨)
AS SELECT EMP_NAME, DEPT_ID
FROM EMPLOYEE
WHERE DEPT_ID = '90';

SELECT * FROM V_EMP;

SELECT COLUMN_NAME, DATA_TYPE, NULLABLE
FROM USER_TAB_COLS
WHERE TABLE_NAME = 'V_EMP';

-- 직급이 사원인 사원의 이름, 부서명, 직급을 출력하는 V_EMP_DEPT_JOB을 생성하자
CREATE OR REPLACE VIEW V_EMP_DEPT_JOB
AS SELECT EMP_NAME, DEPT_NAME, JOB_TITLE
FROM EMPLOYEE
LEFT JOIN DEPARTMENT
USING (DEPT_ID)
LEFT JOIN JOB
USING (JOB_ID)
WHERE JOB_TITLE = '사원';

SELECT * FROM V_EMP_DEPT_JOB;

-- 별칭 사용 VIEW

CREATE OR REPLACE VIEW V_EMP_DEPT_JOB(ENM, DNM, TITLE)
AS SELECT EMP_NAME, DEPT_NAME, JOB_TITLE
FROM EMPLOYEE
LEFT JOIN DEPARTMENT
USING (DEPT_ID)
LEFT JOIN JOB
USING (JOB_ID)
WHERE JOB_TITLE = '사원';
(각 열 명에 AS 로 넣어줘도 됨)

-- 조건함수를 사용한 VIEW 생성(SUBQUERY에 함수로 셀렉트 해왔으면 꼭 별칭(alias) 줘야함)
CREATE OR REPLACE VIEW V_EMP (ENM, GENDER, YEARS)
AS
SELECT EMP_NAME, 
DECODE(SUBSTR(EMP_NO,8,1),'1','남자','3','남자','여자'),
ROUND(MONTHS_BETWEEN(SYSDATE, HIRE_DATE)/12,0)
FROM EMPLOYEE;

-- VIEW 생성 제약조건 : WITH READ ONLY
CREATE OR REPLACE VIEW V_EMP
AS
SELECT * FROM EMPLOYEE
WITH READ ONLY;

UPDATE V_EMP
SET PHONE = NULL; DML OPERATION ON A READ ONLY VIEW 오류

-- VIEW 생성 제약조건 : WITH CHECK OPTION : 조건에 따라 INSERT / UPDATE 작업 제한 (DELETE 는 가능)

CREATE OR REPLACE VIEW V_EMP
AS
SELECT EMP_ID, EMP_NAME, EMP_NO, MARRIAGE FROM EMPLOYEE
WHERE MARRIAGE = 'N' // N애들을 데려다 VIEW를 만들었는데
WITH CHECK OPTION; // 메리지를 Y로 입력하면 체크 옵션 위반

-- 뷰 - 데이터 조회 절차
뷰를 사용한 SQL 구문 해석 -> 데이터 딕셔너리 "USER_VIEWS" 에서 뷰 정의 검색
-> SQL 구문을 실행한 계정이 관련된 베이스 테이블(원본) 테이블에 접근하여 SELECT 권한 확인
-> 뷰 대신 원본 테이블을 기반으로 하는 동등한 작업으로 변환
-> 베이스 테이블(원본)을 대상으로 데이터 조회
뷰삭제 -> DROP VIEW VIEW_NAME;

--시퀀스 : 순차적으로 정수값을 자동으로 생성하는 객체 
CREATE SEQUENCE user_name
INCREMENT BY n  -- 시퀀스 번호 증가/감소 (default 1)
STARTER WITH n -- 시퀀스 시작 값
{ MAXVALUE  n | NOMAXNVALUE } : -- NOMAXVALUE 10^27
{ MINVALUE  n | NOMINVALUE } -- NOMINVALUE -10^26
{ CYCLE | NOCYCLE} -- 최대/ 최소값에 도달하게 되면 반복 여부 결정
{ CACHE  n | NOCACHE } -- 지정한 수량만큼 미리 메모리에 생성여부 결정(최소값 2, 기본값 20)

-- 300부터 310번 까지 5개씩 증가하는 시퀀스를 만들어라
CREATE SEQUENCE SEQ_EMPID
INCREMENT BY 5
START WITH 300
MAXVALUE 310;

-- SEQUENCE의 속성 .NEXTVAL, .currval
SELECT SEQ_EMPID.NEXTVAL FROM DUAL; -- 다음 시퀀스
SELECT SEQ_EMPID.CURRVAL FROM DUAL; -- 최근에 호출한 시퀀스

-- 5부터 15까지 5개씩 증가하는 SEQ
CREATE SEQUENCE SEQ_EMPID02
START WITH 5
INCREMENT BY 5
MAXVALUE 15
CYCLE
NOCACHE;

-- 시퀀스를 수정해보자 단 시퀀스 START WITH 는 수정할 수 없다
ALTER SEQUENCE SEQ_EMPID02
INCREMENT BY 3
MAXVALUE 10
NOCYCLE
NOCACHE;

-- INDEX   (USER_INDEXES)
--책 목차와 같은 색인을 의미한다.  EX) INDEX(키워드) --- 128(위치)
-- 키워드와 해당 내용의 위치가 정렬된 상태로 구성된다.
-- 키워드를 이용해서 내용을 빠르게 찾는 목적을 가진다
-- 데이터 베이스에서 인덱스는 컬럼값을 이용해서 원하는 행을 빠르게 찾기 위한 목적이다.

DEPT 테이블에 DEPTNO 가 있다고 생각하면
INDEX를 DEPTNO로 지정할 경우 정렬을 하고 값을 찾는다	

UNIQUE : 중복값 포함 X
오라클은 PK제약조건을 생성하면 자동으로 해당 컬럼에 Unique index를 생성함
PK를 사용하게 되면 access를 하는데 성능효과가 있다.
Non_UNIQUE : 빈번하게 사용되는 일반 컬럼을 대상으로 생성할때

CREATE [UNIQUE] INDEX index_name ON table_name(column_list | function, expr);

CREATE UNIQUE INDEX IDX_DNM ON DEPARTMENT (DEPT_NAME);
CREATE INDEX IDX_JID ON EMPLOYEE(JOB_ID);

-- EMPLOYEE 테이블의 EMP_NAME 칼럼에 INDEX 생성
CREATE UNIQUE INDEX IDX_DID ON EMPLOYEE(DEPT_ID)
 
-- EMPLOYEE에 생성된 인덱스 현황 조회
SELECT INDEX_NAME, COLUMN_NAME, INDEX_TYPE, UNIQUENESS
FROM USER_INDEXES
JOIN USER_IND_COLUMNS USING(INDEX_NAME, TABLE_NAME)
WHERE TABLE_NAME = 'EMPLOYEE';

--DML (DATA MANIPULATION LANGUAGE) : UPDATE, INSERT, DELETE, TRANSACTION, LOCK

UPDATE table_name
SET conlumn_name = value[, column_name = value ... ] or subquery, default 등
WHERE condition;

UPDATE EMPLOYEE
SET (JOB_ID, SALARY) = (SELECT JOB_ID, SALARY FROM EMPLOYEE WHERE EMP_NAME = '성해교')
WHERE EMP_NAME = '심하균'

--DELETE
DELETE FROM ~~
TRUNCATE TABLE table_name;
-- TRUNCATE
참조되는 테이블의 제약조건을 DISABLE로 지정 > 전체 내용삭제

-- DELETE 때 제약조건이 있으면 삭제를 못한다 ;; 해결은
-- 1. 제약조건 삭제
ALTER TABLE EMPLOYEE DROP CONSTAINTS FK_MGRID;

--2. 제약조건을 추가하되 옵션 지정
ALTER TABLE EMPLOYEE
ADD CONSTRAINTS FK_MGRID FOREIGN KEY(MGR_ID)
REFERENCES EMPLOYEE ON DELETE SET NULL;

-- 3데이터 삭제
DELETE
FROM EMPLOYEE
WHERE EMP_ID = '141';

-- 1. 제약조건 삭제
ALTER TABLE EMPLOYEE DROP CONSTAINTS FK_JOBID;

--2. 제약조건을 추가하되 옵션 지정
ALTER TABLE EMPLOYEE
ADD CONSTRAINTS FK_JOBID FOREIGN KEY(JOB_ID)
REFERENCES JOB ON DELETE CASCADE;

-- 3데이터 삭제
DELETE
FROM EMPLOYEE
WHERE JOB_ID = 'J2';
