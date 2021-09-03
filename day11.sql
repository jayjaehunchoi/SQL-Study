-- 문제 풀이 보호소에서 중성화한 동물
SELECT I.ANIMAL_ID, I.ANIMAL_TYPE, I.NAME
FROM ANIMAL_INS I
LEFT JOIN ANIMAL_OUTS O
ON I.ANIMAL_ID = O.ANIMAL_ID
WHERE I.SEX_UPON_INTAKE != O.SEX_UPON_OUTCOME
ORDER BY ANIMAL_ID;

--트랜잭션 
--데이터 일관성을 유지하려는 목적으로 사용하는 논리적 연관된 작업들의 집합

하나 이상의 연관된 DML 구문
하나 이상의 DDL 구문
트랜잭션 시작 : 첫 DML 구문이 실행될 때 시작
트랜잭션 종료:
1) COMMIT / ROLLBACK 명령이 실행될 때 종류
2) DDL 구문이 실행될 때 종료 -> Auto COMMIT
3) SQL*PLUS OR DBSERVER가 비정상적으로 종료될때 > AUTO ROLLBACK

--트랜잭션 제어
COMMIT (저장) : 변경된 데이터(INSERT, UPDATE, DELETE)를 저장하고 트랜잭션을 종료하는 명령
 COMMIT시 변경내용이 데이터 베이스에 저장 및 반영
 모든 사용자는 변경된 동일한 결과 볼 수 있음
 동일한 행에 대해 다른 변경 작업 가능
 지금까지 설정된 모든 SAVEPOINT 사라짐

ROLLBACK(취소) : 변경 작업을 취소하고 트랜잭션을 종료하는 명령, 기본적으로 데이터 상태를 트랜잭션 시작시점으로 되돌린다.
 ROLLBACK시 데이터 이전상태로 복구
 동일한 행에 대해 다른 변경 작업 가능
 지금까지 설정한 모든 SAVEPOINT 사라짐

SAVEPOINT savepoint_name : 트랜잭션의 특정시점을 기록하는 명령
ROLLBACK TO savepoint_name : 지정한 특정 시점으로 데이터 상태를 되돌릴 수 있음


-- 트랜잭션과 데이터 상태를 확인해보자

ALTER TABLE EMPLOYEE
DISABLE CONSTRAINT FK_MGRID;

SAVEPOINT S0;

SELECT * FROM DEPARTMENT;
INSERT INTO DEPARTMENT VALUES('40', '기획전략팀','A1');

SAVEPOINT S1;
SELECT * FROM EMPLOYEE;
UPDATE EMPLOYEE SET DEPT_ID = '40'
WHERE DEPT_ID IS NULL;

SAVEPOINT S2;
DELETE FROM EMPLOYEE;

ROLLBACK TO S2;
ROLLBACK TO S1;
ROLLBACK;

-- 동시성 LOCK : 다수 사용자가 동시에 동일한 데이터에 접근해서 변경시도 가능
--무결성 보장을 위해 동시성을 제어하는 것이 필요
--데이터 동시성 제어 기법 특징
-- 1) 서로 다른 트랜잭션(세션)이 동시에 동일한 행을 변경할 수 없도록 방지
-- 2) 다른 트랜잭션이 COMMIT되지 않은 변경 내용을 OVERWRITE 할 수 없도록 방지
-- 3) 트랜잭션이 실행되는 동안 자동으로 수행/ 유지/ 관리 됨
JDBC 연동시  dml중 select 제외 conn.commit() or conn.rollback() or conn.setAutoCommit(true/ false);



