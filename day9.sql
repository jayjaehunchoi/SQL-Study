-- 테이블 생성
[기본구문]
CREATE TABLE table_name
(column_name data_type [DEFAULT expr][column_constratint] [table_constraint..]);

-column_constraint[CONSTRAINT costraint_name] constraint_type
-table_constratint[CONSTRAINT constraint_name] constraint type(column_name, ..);

-- Naming Rule
- 테이블, 컬럼 명 : 문자로 시작, 30자 이하, 영문 대/소문자(A~Z, a~z), 숫자 (0~9) 특수문자, 한글만 포함 가능

--CREATE TABLE TEST (
   ID NUMBER(5),
   NAME CHAR(10)
   ADDRESS VARCHAR(2));

CREATE TABLE TEST_01(COL_1 CHAR(10));

-- 제약조건
데이터 무결성 : 데이터베이스에 저장되어 있는 데이터가 손상되거나 원래 의미를 잃지않고 유지하는 상태
데이터 무결성 제약조건 : 데이터의 무결성을 보장하기 위해 오라클에서 지원하는 방법 EX) 유효하지 않는 데이터 입력 방지

--종류
1) NOT NULL : 해당 컬럼에 NULL을 포함하지 않도록함 (컬럼 라벨)
2) UNIQUE : 해당 컬럼 또는 컬럼 조합 값이 유일하도록 (컬럼, 테이블 라벨)
3) PRIMARY KEY : 각 행을 유일하게 식별할 수 있도록 함 (컬럼, 테이블 라벨) PRIMARY KEY = NOT NULL + UNIQUE
4) REFERENCES table : 해당 컬럼이 참조하고 있는 테이블(주 테이블 = 부모테이블) (컬럼, 테이블 라벨)
5) CHECK : 해당 컬럼에 특정 조건을 항상 만족 시키도록 함 (컬럼, 테이블 라벨)

-- 제약조건의 특징
이름으로 관리된다 : 문자로 시작, 길이는 30자, 이름을 지정하지 않으면 자동 생성
 EX) SYS_C000000 형식
생성시기 : 테이블 생성과 동시, 테이블을 생성한 후 추가
컬럼레벨 또는 테이블 레벨에서의 정의 ( 단, NOT NULL 은 컬럼 레벨에서만 가능)


-- TABLE_NOT NULL TEST
CREATE TABLE TABLE_NOTNULL(
ID CHAR(3) NOT NULL,
SNAME VARCHAR(20));

SELECT * FROM TABLE_NOTNULL; -- CONST = C

-- UNIQUE(식별값: 중복 데이터 X 과 NULL 가능) 제약조건 확인 - 단일 컬럼에서
CREATE TABLE TABLE_UNIQUE(
ID CHAR(3) UNIQUE,
SNAME VARCHAR2(20));

INSERT INTO TABLE_UNIQUE VALUES('100','ORACLE');
INSERT INTO TABLE_UNIQUE VALUES('100','ORACLE'); -- CONS = U
--중복이 발생하면 뜨는 오류 
unique constraint (TEST.SYS_C007092) violated : 'ID' 컬럼에 중복값을 입력하려 했기 때문에 발생

-- 제약조건 테이블 확인 PK = P / FK = R
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME = 'TABLE_UNIQUIE';

-- UNIQUE 조합컬럼 (테이블레벨)
CREATE TABLE TABLE_UNIQUE2(
ID CHAR(3),
SNAME VARCHAR(20),
SCODE CHAR(2).
CONSTRAINT TN2_ID_UN UNIQUE(ID, SNAME));

INSERT INTO TABLE_UNIQUE2 
VALUES('100', 'ORACLE', '01');

INSERT INTO TABLE_UNIQUE2 
VALUES('200', 'ORACLE', '01');

INSERT INTO TABLE_UNIQUE2 
VALUES('200', 'ORACLE', '02');

오류 보고 - 200, ORACLE은 UNIQUE 조합이 걸려있기때문에 동시에 중복되면 아래와 같은 오류가 나온다
ORA-00001: unique constraint (TEST.TN2_ID_UN) violated

-- UNIQUE 칼럼 라벨 각각
CREATE TABLE TABLE_UNIQUE3(
ID CHAR(3) UNIQUE,
SNAME VARCHAR(20) UNIQUE,
SCODE CHAR(2));
이렇게 입력하면 둘 중 하나라도 중복 되면 오류가 난다
하지만 NULL은 중복되어도 상관 없다.

--  칼럼 레벨에서 CONSTRAINT 이름 주기

CREATE TABLE TABLE_UNIQUE4
(ID CHAR(3) COSTRAINT TN4_ID_UN UNIQUE,
SNAME VARCHAR2(20) COSTRAINT TN4_SNAME_UN UNIQUE,
SCODE CHAR(2));

IF CONSTRAINT 이름이 같으면 테이블 생성 안됨

-- PRIMARY KEY = UNIQUE + NOT NULL , TABLE 당 1개 생성 가능

CREATE TABLE TABLE_PK(
ID CHAR(3) PRIMARY  KEY,
SNAME VARCHAR(20));

INSERT INTO TABLE_PK VALUES ('100','ORACLE');
중복오류  = unique constraint (TEST.SYS_C007098) violated
NULL 삽입오류 = cannot insert NULL into ("TEST"."TABLE_PK"."ID")

-- PRIMARY KEY 테이블 레벨에서 생성
CREATE TABLE TABLE_PK2(
ID CHAR(3),
SNAME VARCHAR(20),
SCODE CHAR(2),
CONSTRAINT TP2_PK PRIMARY KEY(ID, SNAME);

INSERT INTO TABLE_PK VALUES ('100','ORACLE','02');

조합되는 개별 컬럼에 NULL 허용 안됨, 하지만 조합 중 하나만 다르면 OK , 둘다 같으면 ERROR

-- 칼럼 레벨에서 각각 준다면? 생성 안됨
CREATE TABLE TABLE_PK3(
ID CHAR(3) PRIMARY  KEY,
SNAME VARCHAR(20) PRIMARY  KEY,
SCODE CHAR(2));

ORA-02260: table can have only one primary key


-- 두 테이블은 참조형을 가진 상태이다. (DEPT_ID > FOREIGN KEY 칼럼)
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ( 'EMPLOYEE', 'DEPARTMENT');

-- FOREIGN KEY : 참조테이블의 컬럼값과 일치하거나 NULL 상태를 유지하도록 하는 제약조건
TABLE FK 테이블 생성하며 LOCATION 테이블을 참조하려한다.
1. 주 테이블의 구조를 확인한다.
2. 주 테이블의 제약 조건을 확인한다.
3. 주 테이블의 참조 테이블이 무조건 PK여야 한다.

DESC LOCATION; -- 구조 확인

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE -- 제약조건 확인
FROM USER_CONSTRAINTS
WHERE TABLE_NAME = 'LOCATION';

-- 칼럼 레벨로 FK 생성
CREATE TABLE TABLE_FK(
ID CHAR(3),
SNAME VARCHAR2(2),
LID CHAR(2) CONSTRAINT FK_LID REFERENCES LOCATION (LOCATION_ID)); 
-- 여기서 참조 테이블만 적으면 자동으로 PK를 찾아간다. 
ALTER TABLE TABLE_FK MODIFY SNAME VARCHAR2(20);

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE -- 제약조건 확인
FROM USER_CONSTRAINTS
WHERE TABLE_NAME = 'TABLE_FK';

-- FK 를 테이블레벨에서 생성
CREATE TABLE TABLE_FK2(
ID CHAR(3),
SNAME VARCHAR(20),
LID CHAR(2),
CONSTRAINT FK_LID FOREIGN KEY (LID) REFERENCES LOCATION(LOCATION_ID) );
-- 부모 테이블 컬럼에 PK를 참조하는 것이 원칙이나 만일 명시적으로 컬럼 참조할 때, UNIQUE를 참조할 수 도있다.
-- 명시 X 부모 PK , 명시 O  부모 PK OR UNIQUE

-- 참조키를 생성할때 주의 할 옵션
FOREIGN KEY 제약 조건을 생성할 때 참조 컬럼이 삭제되는 경우

-- 참조키 조합 컬럼, PK TABLE이 조합컬럼이었으면 조합으로 넣어줘야함
CREATE TABLE TABLE_FK5(
ID CHAR(3),
SNAME VARCHAR2(20),
SCODE CHAR(2),
CONSTRAINT TF5_FK FOREIGN KEY(ID, SNAME) REFERENCES TABLE_PK2);


-- CHECK 제약 조건
CREATE TABLE TABLE_CHECK(
EMP_ID CHAR(3) PRIMARY KEY,
SALARY NUMBER CHECK(SALARY > 0),
MARRIAGE CHAR(1),
CONSTRAINT CHK_MGR CHECK(MARRIAGE IN('Y','N')));

INSERT INTO TABLE_CHECK VALUES('100', -100, 'Y')


-- 서브쿼리 통한 생성
CREATE TABLE TABLE_SUBQUERY1
AS
SELECT EMP_ID, EMP_NAME,SALARY, DEPT_NAME, JOB_TITLE
FROM EMPLOYEE
LEFT JOIN DEPARTMENT USING(DEPT_ID)
LEFT JOIN JOB USING(JOB_ID);

-- 서브쿼리 통한 생성2
CREATE TABLE TABLE_SUBQUERY2(EID,ENAME,SAL,DNAME,JTITLE)
AS
SELECT EMP_ID, EMP_NAME,SALARY, DEPT_NAME, JOB_TITLE
FROM EMPLOYEE
LEFT JOIN DEPARTMENT USING(DEPT_ID)
LEFT JOIN JOB USING(JOB_ID);
DESC TABLE_SUBQUERY1;

-- 서브쿼리 통한 생성3 (테이블 생성시 제약조건 생성)
CREATE TABLE TABLE_SUBQUERY3(EID, ENAME, SAL CHECK (SAL > 2000000),DNAME, JTITLE DEFAULT 'N/A' NULL)
AS
SELECT EMP_ID, EMP_NAME, SALARY, DEPT_NAME, JOB_TITLE
FROM EMPLOYEE
LEFT JOIN DEPARTMENT USING(DEPT_ID)
LEFT JOIN JOB USING(JOB_ID)
WHERE SALARY > 2000000;

-- 제약조건 확인
SELECT CONSTRAINT_NAME AS 이름,
CONSTRAINT_TYPE AS 유형,
COLUMN_NAME AS 컬럼,
SEARCH_CONDITION AS 내용,
R_CONSTRAINT_NAME AS 참조,
DELETE_RULE AS 삭제규칙
FROM USER_CONSTRAINTS
JOIN USER_CONS_COLUMNS USING(CONSTRAINT_NAME, TABLE_NAME);

-- 테이블 수정 
ALTER TABLE table_name
ADD (column_name datatype [default 제약조건]) | ADD costraint
MODIFY (column_name datatype [default 제약조건]) 
DROP COLUMN column_name[CASCADE CONSTRAINTS]

-- 이름 변경 
ALTER TABLE old_table_name RENAME TO new_table_name;
RENAME old_table_name TO new_table_name
ALTER TABLE table_name RENAME COLUMN old_column_name TO new_column_name;
ALTER TABLE table_name RENAME CONSTRAINT old_CONST_name TO new_CONST_name;

-- ADD로 칼럼 생성 (맨 뒤에 생김)
ALTER TABLE DEPARTMENT
ADD (MGR_ID CHAR(3));

-- 기본값 추가
ALTER TABLE DEPARTMENT
ADD (MGR_ID02 CHAR(3) DEFAULT '101');

-- 제약조건 추가하면서 테이블 생성
CREATE TABLE EMP3
AS
SELECT * FROM EMPLOYEE;

ALTER TABLE EMP3
ADD PRIMARY KEY (EMP_ID)
ADD UNIQUE (EMP_NO)
MODIFY HIRE_DATE NOT NULL; -- NOT NULL 제약조건은 MODIFY로 넣기


