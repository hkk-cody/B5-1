# SQLite SQL 문법 정리

이 문서는 SQLite에서 자주 사용하는 SQL 문법을 과제 진행용으로 정리한 자료입니다.
예시는 현재 도서 대여 DB의 `category`, `member`, `book`, `rental` 테이블을 기준으로 작성했습니다.

추천 읽기 순서는 다음과 같습니다.

1. 데이터베이스 기본 개념을 먼저 읽습니다.
2. SQLite 실행 방법을 확인합니다.
3. 테이블, 타입, 제약조건을 이해합니다.
4. 데이터 추가, 조회, 수정, 삭제 문법을 익힙니다.
5. JOIN, GROUP BY, 서브쿼리, 인덱스, 함수, 자주 하는 실수를 차례로 봅니다.

## 1. 데이터베이스 기본 개념

데이터베이스는 데이터를 아무렇게나 모아 두는 공간이 아니라, 정해진 구조와 규칙에 따라 저장하고 조회하는 시스템입니다.
엑셀처럼 표 형태로 볼 수 있지만, 테이블 사이의 관계와 제약조건을 명확하게 관리할 수 있다는 점이 중요합니다.

### DB와 DBMS

`DB`는 데이터베이스 자체를 뜻합니다.
예를 들어 `library.db` 파일은 SQLite 데이터베이스 파일입니다.

`DBMS`는 Database Management System의 줄임말로, 데이터베이스를 관리하는 프로그램입니다.
SQLite, MySQL, PostgreSQL 같은 것들이 DBMS입니다.

이번 과제에서는 SQLite라는 DBMS를 사용하고, `library.db`라는 DB 파일을 만듭니다.

### 테이블, 행, 컬럼

관계형 데이터베이스는 데이터를 테이블 단위로 저장합니다.

| 개념 | 의미 | 과제 예시 |
| --- | --- | --- |
| 테이블 | 같은 종류의 데이터를 모아 놓은 표 | `member`, `book`, `rental` |
| 행 | 실제 데이터 1건 | 회원 1명, 책 1권, 대여 기록 1건 |
| 컬럼 | 데이터의 항목 | `name`, `title`, `rented_at` |

예를 들어 `member` 테이블은 회원 정보를 저장하고, 각 행은 회원 한 명을 의미합니다.

### 스키마

스키마는 데이터베이스의 설계도입니다.
어떤 테이블이 있고, 각 테이블에 어떤 컬럼이 있으며, 어떤 규칙으로 연결되는지를 정의합니다.

이번 과제에서 `schema.sql`은 스키마를 만드는 파일입니다.

```sql
CREATE TABLE member (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);
```

### PK

PK는 Primary Key의 줄임말이며, 각 행을 구분하는 고유한 값입니다.
한 테이블 안에서 PK 값은 중복될 수 없습니다.

```sql
id INTEGER PRIMARY KEY AUTOINCREMENT
```

회원 이름은 같을 수 있지만 `member.id`는 같으면 안 됩니다.
그래서 이름보다 id가 데이터를 구분하기에 더 안전합니다.

### FK

FK는 Foreign Key의 줄임말이며, 다른 테이블의 PK를 참조하는 컬럼입니다.
FK를 사용하면 테이블 사이의 관계를 만들 수 있습니다.

```sql
member_id INTEGER NOT NULL,
FOREIGN KEY (member_id) REFERENCES member(id)
```

위 예시는 `rental.member_id`가 `member.id`를 참조한다는 뜻입니다.
즉, 대여 기록이 어떤 회원의 기록인지 연결합니다.

### 1:N 관계

1:N 관계는 한쪽 데이터 1개가 다른 쪽 데이터 여러 개와 연결되는 관계입니다.

이번 과제의 예시는 다음과 같습니다.

| 관계 | 의미 |
| --- | --- |
| `category` 1 : N `book` | 카테고리 하나에 여러 책이 속할 수 있음 |
| `member` 1 : N `rental` | 회원 한 명이 여러 번 책을 빌릴 수 있음 |
| `book` 1 : N `rental` | 책 한 권이 여러 번 대여될 수 있음 |

이 관계를 잘 설계해야 JOIN으로 연결된 데이터를 자연스럽게 조회할 수 있습니다.

### 제약조건

제약조건은 잘못된 데이터가 들어오지 않도록 막는 규칙입니다.

| 제약조건 | 의미 |
| --- | --- |
| `NOT NULL` | 반드시 값이 있어야 함 |
| `UNIQUE` | 중복 값을 허용하지 않음 |
| `CHECK` | 정해진 조건을 만족해야 함 |
| `FOREIGN KEY` | 존재하는 다른 테이블 데이터만 참조 가능 |

예를 들어 이메일은 중복되면 안 되므로 `UNIQUE`를 사용할 수 있습니다.

```sql
email TEXT NOT NULL UNIQUE
```

### CRUD

CRUD는 데이터를 다루는 기본 행동 4가지를 뜻합니다.

| 이름 | SQL | 의미 |
| --- | --- | --- |
| Create | `INSERT` | 데이터 추가 |
| Read | `SELECT` | 데이터 조회 |
| Update | `UPDATE` | 데이터 수정 |
| Delete | `DELETE` | 데이터 삭제 |

대부분의 서비스 기능은 결국 CRUD를 조합해서 만들어집니다.

### 정규화

정규화는 데이터를 역할에 맞게 여러 테이블로 나누는 설계 방식입니다.
같은 정보를 계속 반복해서 저장하지 않고, 필요한 곳에서 FK로 연결합니다.

예를 들어 대여 기록마다 회원 이름과 이메일을 직접 저장하면 회원 정보가 바뀔 때 모든 대여 기록을 수정해야 합니다.
대신 `member` 테이블에 회원 정보를 한 번만 저장하고, `rental.member_id`로 연결하면 더 안전합니다.

이번 과제에서는 정규화를 깊게 파기보다는 "회원, 책, 카테고리, 대여 기록을 역할별로 나눈다" 정도를 이해하면 충분합니다.

### 쿼리

쿼리는 데이터베이스에 요청하는 SQL 문장입니다.

```sql
SELECT title, author
FROM book
WHERE available_copies > 0;
```

위 쿼리는 "대여 가능한 책의 제목과 저자를 보여줘"라는 요청입니다.

### 트랜잭션

트랜잭션은 여러 작업을 하나의 작업 단위로 묶는 개념입니다.
중간에 문제가 생기면 전체를 되돌릴 수 있습니다.

```sql
BEGIN;
UPDATE rental SET status = 'RETURNED' WHERE id = 2;
ROLLBACK;
```

과제에서는 UPDATE와 DELETE를 실습하되, 원본 데이터를 보존하기 위해 `ROLLBACK`을 사용합니다.

### 인덱스

인덱스는 데이터를 더 빠르게 찾기 위한 색인입니다.
책 뒤쪽의 찾아보기와 비슷합니다.

```sql
CREATE INDEX idx_rental_member_id ON rental(member_id);
```

회원별 대여 내역처럼 자주 검색하거나 JOIN에 자주 쓰는 컬럼에 인덱스를 만들면 도움이 됩니다.

## 2. SQLite 기본 실행

SQLite는 하나의 DB 파일을 열어서 사용합니다.

```bash
sqlite3 library.db
```

SQL 파일을 실행할 때는 다음처럼 입력합니다.

```bash
sqlite3 library.db < schema.sql
sqlite3 library.db < seed.sql
sqlite3 -header -column library.db < queries.sql
```

결과를 텍스트 파일로 저장하려면 다음처럼 실행합니다.

```bash
sqlite3 -header -column library.db < queries.sql > results/query_results.txt
```

## 3. SQLite CLI에서 자주 쓰는 명령

아래 명령은 SQL이 아니라 SQLite CLI 전용 명령입니다.

```sql
.tables              -- 현재 DB의 테이블 목록 보기
.schema book         -- book 테이블 생성 구조 보기
.headers on          -- 조회 결과에 컬럼명 표시
.mode column         -- 결과를 컬럼 형태로 보기
.mode box            -- 결과를 박스 형태로 보기
.quit                -- SQLite 종료
```

## 4. 외래 키 활성화

SQLite는 외래 키 검사를 명시적으로 켜는 것이 안전합니다.

```sql
PRAGMA foreign_keys = ON;
```

외래 키가 켜져 있으면 존재하지 않는 회원이나 책을 대여 기록에 넣을 수 없습니다.

```sql
INSERT INTO rental (member_id, book_id, rented_at, due_at, status)
VALUES (999, 1, '2026-03-01', '2026-03-15', 'BORROWED');
```

위 예시는 `member_id = 999`인 회원이 없으면 실패합니다.

## 5. 테이블 생성

테이블은 `CREATE TABLE`로 만듭니다.

```sql
CREATE TABLE member (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    joined_at TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE'
);
```

## 6. SQLite 데이터 타입

SQLite에서 자주 쓰는 컬럼 타입은 다음과 같습니다.

| 타입 | 설명 |
| --- | --- |
| `INTEGER` | 정수. id, 개수, 연도처럼 소수점이 없는 숫자에 사용 |
| `TEXT` | 문자열. 이름, 제목, 이메일, 날짜 문자열에 사용 |
| `REAL` | 실수. 평점, 비율, 금액 계산 결과처럼 소수점이 필요한 값에 사용 |
| `BLOB` | 바이너리 데이터. 이미지나 파일처럼 그대로 저장할 데이터에 사용 |
| `NUMERIC` | 숫자처럼 비교 가능한 값. 날짜, 불리언, 정밀 숫자 등에 사용 가능 |

SQLite는 타입을 비교적 유연하게 다룹니다.
그래도 컬럼의 의미에 맞는 타입을 쓰는 것이 좋습니다.

SQLite는 MySQL이나 PostgreSQL처럼 타입을 아주 엄격하게 강제하지 않습니다.
예를 들어 `INTEGER` 컬럼에 문자열을 넣으려는 시도를 해도 상황에 따라 저장될 수 있습니다.
그래서 SQLite에서는 타입뿐 아니라 `NOT NULL`, `CHECK`, `FOREIGN KEY` 같은 제약조건을 함께 사용하는 것이 중요합니다.

### 타입 선호도

SQLite는 컬럼에 적힌 타입 이름을 보고 내부적으로 아래 5가지 성격 중 하나로 해석합니다.
이를 타입 선호도(type affinity)라고 합니다.

| 타입 선호도 | 대표 선언 예시 | 주로 쓰는 상황 |
| --- | --- | --- |
| `INTEGER` | `INTEGER`, `INT` | 기본 키, 수량, 연도 |
| `TEXT` | `TEXT`, `VARCHAR(100)` | 이름, 제목, 설명 |
| `REAL` | `REAL`, `DOUBLE`, `FLOAT` | 평균, 비율, 소수점 숫자 |
| `NUMERIC` | `NUMERIC`, `DECIMAL`, `BOOLEAN`, `DATE`, `DATETIME` | 날짜, 참/거짓, 정밀 숫자 |
| `BLOB` | `BLOB` | 파일, 이미지 같은 바이너리 |

SQLite에서는 `VARCHAR(100)`이라고 써도 길이 100자를 엄격하게 막지 않습니다.
길이를 제한하고 싶다면 `CHECK (length(column_name) <= 100)` 같은 조건을 추가해야 합니다.

### 문자열 타입

SQLite에서 문자열은 사실상 `TEXT` 하나를 기본으로 생각하면 됩니다.
다른 DB처럼 `CHAR`, `VARCHAR`, `TEXT`를 엄격하게 나눠서 관리하지 않습니다.

아래 선언들은 SQLite에서 대부분 문자열 성격인 `TEXT` 타입 선호도로 취급됩니다.

| 선언 예시 | SQLite에서의 취급 | 설명 |
| --- | --- | --- |
| `TEXT` | 문자열 | SQLite에서 가장 일반적인 문자열 타입 |
| `VARCHAR(100)` | 문자열 | 길이 100자를 자동으로 강제하지 않음 |
| `CHAR(10)` | 문자열 | 고정 길이 문자열처럼 선언해도 길이를 자동으로 맞추지 않음 |
| `CLOB` | 문자열 | 긴 문자열을 저장할 때 쓰는 이름 |
| `NCHAR`, `NVARCHAR` | 문자열 | 유니코드 문자열처럼 선언할 수 있지만 SQLite에서는 `TEXT`처럼 다룸 |

과제에서는 문자열 컬럼을 대부분 `TEXT`로 작성하면 충분합니다.

```sql
title TEXT NOT NULL,
email TEXT NOT NULL UNIQUE,
status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
```

길이를 제한하고 싶다면 `VARCHAR(10)`만 쓰지 말고 `CHECK`를 함께 사용합니다.

```sql
name TEXT NOT NULL CHECK (length(name) <= 10)
```

즉, SQLite에서는 "문자열은 `TEXT`를 기본으로 쓰고, 길이 제한이나 허용 값 제한은 `CHECK`로 직접 건다"고 기억하면 됩니다.

### 문자열 따옴표

SQL에서 문자열 값은 작은따옴표로 감싸는 것이 표준입니다.

```sql
SELECT *
FROM member
WHERE name = '김민준';
```

컬럼명이나 테이블명은 따옴표 없이 쓰는 것이 가장 깔끔합니다.
꼭 감싸야 한다면 SQLite에서는 큰따옴표를 사용할 수 있습니다.

```sql
SELECT "name"
FROM "member";
```

혼동을 줄이기 위해 과제에서는 테이블명과 컬럼명을 영어 소문자와 밑줄로 만들고, 문자열 값만 작은따옴표로 감싸는 방식을 추천합니다.

### 날짜와 시간

SQLite에는 별도의 엄격한 `DATE` 타입이 없습니다.
보통 날짜는 `TEXT`로 저장하고 `YYYY-MM-DD` 형식을 사용합니다.

```sql
joined_at TEXT NOT NULL
```

예시는 다음과 같습니다.

```sql
INSERT INTO member (name, email, phone, joined_at)
VALUES ('김민준', 'minjun@example.com', '010-1111-2222', '2026-01-03');
```

`YYYY-MM-DD` 형식으로 저장하면 문자열 정렬을 해도 날짜 순서가 잘 맞습니다.

```sql
SELECT name, joined_at
FROM member
ORDER BY joined_at DESC;
```

날짜 계산은 `date`, `datetime`, `julianday` 같은 SQLite 함수를 사용합니다.

```sql
SELECT date('now') AS today;
SELECT julianday('2026-02-16') - julianday('2026-02-01') AS days;
```

### 참/거짓 값

SQLite에는 엄격한 `BOOLEAN` 타입이 없습니다.
보통 아래 두 방식 중 하나를 사용합니다.

```sql
-- 1은 참, 0은 거짓으로 저장
is_active INTEGER NOT NULL CHECK (is_active IN (0, 1))
```

```sql
-- 상태를 문자열로 저장
status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
```

이번 과제에서는 사람이 읽기 쉬운 상태값이 필요하므로 `status TEXT`와 `CHECK`를 사용했습니다.

### 돈과 소수

금액처럼 정확해야 하는 값은 소수점 오차를 조심해야 합니다.
SQLite에서 돈을 다룬다면 실수인 `REAL`보다 정수 단위로 저장하는 방법이 안전합니다.

```sql
-- 12900원을 저장
price_won INTEGER NOT NULL CHECK (price_won >= 0)
```

평균 대여 기간처럼 약간의 소수점 오차가 큰 문제가 아닌 값은 `REAL` 계산을 사용해도 괜찮습니다.

### 이번 과제에서 사용한 타입

| 컬럼 예시 | 사용 타입 | 이유 |
| --- | --- | --- |
| `id` | `INTEGER` | 자동 증가하는 기본 키 |
| `name`, `title`, `email` | `TEXT` | 문자 데이터 |
| `joined_at`, `rented_at`, `due_at` | `TEXT` | `YYYY-MM-DD` 날짜 문자열 |
| `published_year` | `INTEGER` | 출판 연도 |
| `total_copies`, `available_copies` | `INTEGER` | 책 권수 |
| `status` | `TEXT` | 사람이 읽기 쉬운 상태값 |

타입 선택의 핵심은 "이 컬럼으로 무엇을 저장하고, 어떻게 조회할 것인가?"입니다.
숫자로 계산할 값은 `INTEGER`나 `REAL`, 사람이 읽는 문자는 `TEXT`, 날짜는 과제 수준에서는 `TEXT`로 저장하면 충분합니다.

## 7. 제약조건

제약조건은 잘못된 데이터가 들어오지 않도록 막는 규칙입니다.

```sql
CREATE TABLE book (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    isbn TEXT NOT NULL UNIQUE,
    published_year INTEGER CHECK (published_year BETWEEN 1900 AND 2100),
    FOREIGN KEY (category_id) REFERENCES category(id)
);
```

| 제약조건 | 의미 |
| --- | --- |
| `PRIMARY KEY` | 행을 구분하는 기본 키 |
| `AUTOINCREMENT` | 숫자 PK를 자동 증가 |
| `NOT NULL` | 빈 값 저장 금지 |
| `UNIQUE` | 중복 값 저장 금지 |
| `CHECK` | 조건에 맞는 값만 저장 |
| `DEFAULT` | 값을 생략했을 때 기본값 사용 |
| `FOREIGN KEY` | 다른 테이블의 PK 참조 |

## 8. 테이블 삭제

테이블은 `DROP TABLE`로 삭제합니다.

```sql
DROP TABLE IF EXISTS rental;
```

외래 키 관계가 있으면 자식 테이블을 먼저 삭제하는 것이 안전합니다.
예를 들어 `rental`은 `member`, `book`을 참조하므로 먼저 삭제합니다.

## 9. 데이터 추가

데이터는 `INSERT INTO`로 추가합니다.

```sql
INSERT INTO category (name, description)
VALUES ('문학', '소설, 시, 에세이 등 문학 도서');
```

여러 행을 한 번에 넣을 수도 있습니다.

```sql
INSERT INTO category (name, description) VALUES
('문학', '문학 도서'),
('역사', '역사 도서'),
('과학', '과학 도서');
```

외래 키가 있는 테이블은 참조 대상 데이터가 먼저 있어야 합니다.
예를 들어 `book.category_id`는 `category.id`를 참조하므로 카테고리를 먼저 넣어야 합니다.

## 10. 기본 조회

전체 컬럼을 조회할 때는 `*`를 사용합니다.

```sql
SELECT *
FROM book;
```

필요한 컬럼만 조회할 수도 있습니다.

```sql
SELECT title, author, published_year
FROM book;
```

## 11. 조건 조회

`WHERE`는 조건에 맞는 데이터만 조회합니다.

```sql
SELECT title, author
FROM book
WHERE category_id = 4;
```

비교 연산자는 다음처럼 사용합니다.

```sql
SELECT title, available_copies
FROM book
WHERE available_copies >= 3;
```

여러 조건을 함께 쓸 수 있습니다.

```sql
SELECT title, author
FROM book
WHERE category_id = 4
  AND available_copies > 0;
```

## 12. 정렬과 개수 제한

`ORDER BY`는 결과를 정렬합니다.

```sql
SELECT title, published_year
FROM book
ORDER BY published_year DESC;
```

`LIMIT`은 조회할 행 수를 제한합니다.

```sql
SELECT id, member_id, book_id, rented_at
FROM rental
ORDER BY rented_at DESC
LIMIT 5;
```

## 13. 문자열 검색

`LIKE`는 문자열 일부를 검색할 때 사용합니다.

```sql
SELECT title, author
FROM book
WHERE title LIKE '%SQL%';
```

`%`는 글자가 몇 개든 올 수 있다는 뜻입니다.

| 패턴 | 의미 |
| --- | --- |
| `'SQL%'` | SQL로 시작 |
| `'%SQL'` | SQL로 끝남 |
| `'%SQL%'` | SQL을 포함 |

한 글자만 아무 글자나 허용하려면 `_`를 사용합니다.

```sql
SELECT title
FROM book
WHERE title LIKE 'SQL_';
```

위 조건은 `SQL1`, `SQLA`처럼 `SQL` 뒤에 한 글자가 더 있는 값을 찾습니다.

### LIKE와 대소문자

SQLite의 기본 `LIKE`는 영어 알파벳에 대해 대소문자를 엄격하게 구분하지 않는 경우가 많습니다.
예를 들어 설정에 따라 `'sql'`로 검색해도 `'SQL'`이 검색될 수 있습니다.

```sql
SELECT title
FROM book
WHERE title LIKE '%sql%';
```

대소문자를 구분하는 검색이 꼭 필요하면 `GLOB`를 사용할 수 있습니다.
`GLOB`는 `LIKE`와 달리 `*`를 여러 글자 패턴으로 사용합니다.

```sql
SELECT title
FROM book
WHERE title GLOB '*SQL*';
```

과제 수준에서는 보통 `LIKE`만 알아도 충분합니다.

### 문자열 길이 확인

문자열 길이는 `length()` 함수로 확인합니다.

```sql
SELECT name, length(name) AS name_length
FROM member;
```

길이 제한을 제약조건으로 걸 때도 `length()`를 사용할 수 있습니다.

```sql
CREATE TABLE short_label (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT NOT NULL CHECK (length(label) <= 20)
);
```

### 문자열 합치기

SQLite에서 문자열을 합칠 때는 `||` 연산자를 사용합니다.

```sql
SELECT name || ' / ' || email AS member_contact
FROM member;
```

MySQL의 `CONCAT(name, email)`과 다르므로 주의합니다.

### 문자열 일부 자르기

`substr()` 함수로 문자열 일부를 가져올 수 있습니다.

```sql
SELECT title, substr(title, 1, 5) AS short_title
FROM book;
```

SQLite의 `substr()` 시작 위치는 1부터 셉니다.

### 공백 제거

사용자가 입력한 문자열 앞뒤에 공백이 있을 수 있습니다.
이때 `trim()`을 사용할 수 있습니다.

```sql
SELECT trim('  SQL 첫걸음  ') AS cleaned_text;
```

관련 함수는 다음과 같습니다.

| 함수 | 설명 |
| --- | --- |
| `trim(text)` | 양쪽 공백 제거 |
| `ltrim(text)` | 왼쪽 공백 제거 |
| `rtrim(text)` | 오른쪽 공백 제거 |

### 정렬 기준

문자열 정렬은 `ORDER BY`로 합니다.

```sql
SELECT title
FROM book
ORDER BY title ASC;
```

영어 대소문자를 무시하고 정렬하고 싶다면 `COLLATE NOCASE`를 사용할 수 있습니다.

```sql
SELECT title
FROM book
ORDER BY title COLLATE NOCASE;
```

한글 정렬은 환경과 데이터에 따라 기대와 다를 수 있습니다.
이번 과제에서는 기본 정렬만 사용해도 충분합니다.

## 14. NULL 처리

`NULL`은 값이 없다는 뜻입니다.
`NULL`은 `=`로 비교하지 않고 `IS NULL`을 사용합니다.

```sql
SELECT id, member_id, book_id
FROM rental
WHERE returned_at IS NULL;
```

값이 있는 행은 `IS NOT NULL`로 찾습니다.

```sql
SELECT id, returned_at
FROM rental
WHERE returned_at IS NOT NULL;
```

## 15. 데이터 수정

`UPDATE`는 기존 데이터를 수정합니다.

```sql
UPDATE rental
SET status = 'RETURNED',
    returned_at = '2026-02-16'
WHERE id = 2;
```

`WHERE`를 빼면 모든 행이 수정될 수 있으므로 주의해야 합니다.

## 16. 데이터 삭제

`DELETE`는 데이터를 삭제합니다.

```sql
DELETE FROM rental
WHERE id = 12;
```

`DELETE`도 `WHERE`를 빼면 모든 행이 삭제될 수 있으므로 주의해야 합니다.

## 17. 트랜잭션

트랜잭션은 여러 SQL을 하나의 작업 단위로 묶는 기능입니다.

```sql
BEGIN;

UPDATE rental
SET status = 'RETURNED'
WHERE id = 2;

ROLLBACK;
```

`ROLLBACK`은 변경 내용을 되돌립니다.
실습 중 데이터를 망가뜨리지 않고 UPDATE나 DELETE를 확인할 때 유용합니다.

변경 내용을 확정하려면 `COMMIT`을 사용합니다.

```sql
BEGIN;

UPDATE rental
SET status = 'RETURNED'
WHERE id = 2;

COMMIT;
```

## 18. INNER JOIN

`INNER JOIN`은 두 테이블 모두에 연결되는 데이터만 보여줍니다.

```sql
SELECT r.id, m.name, b.title, r.rented_at
FROM rental r
INNER JOIN member m ON r.member_id = m.id
INNER JOIN book b ON r.book_id = b.id;
```

위 쿼리는 대여 기록에 회원 이름과 책 제목을 붙여서 보여줍니다.

## 19. LEFT JOIN

`LEFT JOIN`은 왼쪽 테이블의 데이터를 모두 보여주고, 오른쪽에 연결된 데이터가 없으면 `NULL`로 보여줍니다.

```sql
SELECT m.name, COUNT(r.id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name;
```

대여 기록이 없는 회원도 보고 싶을 때 유용합니다.

## 20. GROUP BY

`GROUP BY`는 같은 값을 가진 행을 묶어서 집계합니다.

```sql
SELECT status, COUNT(*) AS status_count
FROM rental
GROUP BY status;
```

자주 쓰는 집계 함수는 다음과 같습니다.

| 함수 | 의미 |
| --- | --- |
| `COUNT(*)` | 행 개수 |
| `SUM(column)` | 합계 |
| `AVG(column)` | 평균 |
| `MIN(column)` | 최솟값 |
| `MAX(column)` | 최댓값 |

## 21. HAVING

`WHERE`는 그룹으로 묶기 전의 조건이고, `HAVING`은 그룹으로 묶은 뒤의 조건입니다.

```sql
SELECT member_id, COUNT(*) AS rental_count
FROM rental
GROUP BY member_id
HAVING COUNT(*) >= 2;
```

위 쿼리는 대여 기록이 2개 이상인 회원만 보여줍니다.

## 22. 서브쿼리

서브쿼리는 SQL 안에 들어 있는 또 다른 SQL입니다.

```sql
SELECT title, author
FROM book
WHERE category_id = (
    SELECT id
    FROM category
    WHERE name = '기술'
);
```

위 쿼리는 먼저 `기술` 카테고리의 id를 찾고, 그 id에 해당하는 책을 조회합니다.

## 23. 날짜 함수

SQLite는 날짜를 보통 `TEXT`로 저장하고 날짜 함수로 계산합니다.

```sql
SELECT date('now') AS today;
```

날짜 차이를 계산할 때는 `julianday`를 사용할 수 있습니다.

```sql
SELECT julianday('2026-02-16') - julianday('2026-02-01') AS days;
```

반납된 대여 기록의 평균 대여 기간은 다음처럼 계산할 수 있습니다.

```sql
SELECT ROUND(AVG(julianday(returned_at) - julianday(rented_at)), 1) AS avg_rental_days
FROM rental
WHERE returned_at IS NOT NULL;
```

## 24. CASE

`CASE`는 조건에 따라 다른 값을 보여줄 때 사용합니다.

```sql
SELECT title,
       CASE
           WHEN available_copies = 0 THEN '대여 불가'
           WHEN available_copies <= 2 THEN '수량 적음'
           ELSE '대여 가능'
       END AS availability_status
FROM book;
```

## 25. 인덱스

인덱스는 조회를 빠르게 하기 위한 구조입니다.
자주 검색하거나 JOIN에 사용하는 컬럼에 만들면 좋습니다.

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_id
ON rental(member_id);
```

생성된 인덱스는 다음처럼 확인할 수 있습니다.

```sql
SELECT name, tbl_name, sql
FROM sqlite_master
WHERE type = 'index';
```

인덱스를 너무 많이 만들면 INSERT, UPDATE, DELETE가 느려질 수 있습니다.

## 26. 별칭

별칭은 컬럼명이나 테이블명을 짧게 부르는 방법입니다.

```sql
SELECT b.title AS book_title,
       c.name AS category_name
FROM book b
INNER JOIN category c ON b.category_id = c.id;
```

`AS`는 결과 컬럼 이름을 보기 좋게 바꿀 때도 사용합니다.

## 27. 중복 제거

`DISTINCT`는 중복 값을 제거합니다.

```sql
SELECT DISTINCT status
FROM rental;
```

## 28. SQLite 함수 모음

SQLite 함수는 값을 계산하거나, 문자열을 다듬거나, 날짜를 처리하거나, 여러 행을 집계할 때 사용합니다.
함수는 보통 `함수명(값)` 형태로 작성합니다.

```sql
SELECT length(title) AS title_length
FROM book;
```

### 문자열 함수

문자열 함수는 `TEXT` 값을 다룰 때 사용합니다.

| 함수 | 설명 | 예시 |
| --- | --- | --- |
| `length(text)` | 문자열 길이 | `length(title)` |
| `substr(text, start, count)` | 문자열 일부 추출 | `substr(title, 1, 5)` |
| `trim(text)` | 양쪽 공백 제거 | `trim(name)` |
| `ltrim(text)` | 왼쪽 공백 제거 | `ltrim(name)` |
| `rtrim(text)` | 오른쪽 공백 제거 | `rtrim(name)` |
| `upper(text)` | 영어 대문자로 변경 | `upper(email)` |
| `lower(text)` | 영어 소문자로 변경 | `lower(email)` |
| `replace(text, old, new)` | 문자열 치환 | `replace(phone, '-', '')` |

예시는 다음과 같습니다.

```sql
SELECT title,
       length(title) AS title_length,
       substr(title, 1, 5) AS short_title
FROM book;
```

전화번호에서 `-`를 제거할 수도 있습니다.

```sql
SELECT name, replace(phone, '-', '') AS normalized_phone
FROM member;
```

### 숫자 함수

숫자 함수는 계산 결과를 보기 좋게 만들거나 절댓값, 반올림 등을 처리할 때 사용합니다.

| 함수 | 설명 | 예시 |
| --- | --- | --- |
| `round(number, digits)` | 반올림 | `round(12.345, 1)` |
| `abs(number)` | 절댓값 | `abs(-10)` |
| `max(a, b, ...)` | 가장 큰 값 | `max(total_copies, available_copies)` |
| `min(a, b, ...)` | 가장 작은 값 | `min(total_copies, available_copies)` |

```sql
SELECT title,
       total_copies - available_copies AS borrowed_copies,
       round(available_copies * 100.0 / total_copies, 1) AS available_percent
FROM book;
```

위 쿼리는 책별 대여 중인 권수와 대여 가능 비율을 계산합니다.

### 날짜와 시간 함수

SQLite는 날짜를 보통 `TEXT`로 저장하고, 날짜 함수로 계산합니다.

| 함수 | 설명 | 예시 |
| --- | --- | --- |
| `date(value)` | 날짜 반환 | `date('now')` |
| `datetime(value)` | 날짜와 시간 반환 | `datetime('now')` |
| `time(value)` | 시간 반환 | `time('now')` |
| `julianday(value)` | 날짜를 계산 가능한 숫자로 변환 | `julianday(due_at)` |
| `strftime(format, value)` | 원하는 형식으로 날짜 출력 | `strftime('%Y-%m', rented_at)` |

오늘 날짜는 다음처럼 구합니다.

```sql
SELECT date('now') AS today;
```

대여 기간은 `julianday()`로 계산할 수 있습니다.

```sql
SELECT id,
       julianday(due_at) - julianday(rented_at) AS allowed_days
FROM rental;
```

월별 대여 건수를 구할 때는 `strftime()`이 유용합니다.

```sql
SELECT strftime('%Y-%m', rented_at) AS rental_month,
       COUNT(*) AS rental_count
FROM rental
GROUP BY strftime('%Y-%m', rented_at);
```

자주 쓰는 날짜 형식은 다음과 같습니다.

| 형식 | 의미 | 예시 결과 |
| --- | --- | --- |
| `%Y` | 연도 | `2026` |
| `%m` | 월 | `02` |
| `%d` | 일 | `15` |
| `%H` | 시 | `09` |
| `%M` | 분 | `30` |
| `%S` | 초 | `05` |

### NULL 처리 함수

`NULL`은 값이 없다는 뜻입니다.
계산이나 문자열 합치기에서 `NULL`이 섞이면 결과가 예상과 달라질 수 있으므로 함수로 처리하면 좋습니다.

| 함수 | 설명 | 예시 |
| --- | --- | --- |
| `ifnull(value, fallback)` | 값이 NULL이면 대체값 사용 | `ifnull(returned_at, '미반납')` |
| `coalesce(a, b, c, ...)` | NULL이 아닌 첫 번째 값 사용 | `coalesce(returned_at, due_at, rented_at)` |
| `nullif(a, b)` | 두 값이 같으면 NULL 반환 | `nullif(status, 'BORROWED')` |

```sql
SELECT id,
       ifnull(returned_at, '아직 반납 안 함') AS return_status
FROM rental;
```

`coalesce()`는 여러 후보 중 비어 있지 않은 값을 고를 때 좋습니다.

```sql
SELECT id,
       coalesce(returned_at, due_at) AS display_date
FROM rental;
```

### 집계 함수

집계 함수는 여러 행을 하나의 결과로 계산합니다.
보통 `GROUP BY`와 함께 사용합니다.

| 함수 | 설명 | 예시 |
| --- | --- | --- |
| `COUNT(*)` | 행 개수 | `COUNT(*)` |
| `COUNT(column)` | NULL이 아닌 값 개수 | `COUNT(returned_at)` |
| `SUM(column)` | 합계 | `SUM(total_copies)` |
| `AVG(column)` | 평균 | `AVG(total_copies)` |
| `MIN(column)` | 최솟값 | `MIN(rented_at)` |
| `MAX(column)` | 최댓값 | `MAX(rented_at)` |

```sql
SELECT status,
       COUNT(*) AS rental_count
FROM rental
GROUP BY status;
```

`COUNT(*)`는 행 자체를 세고, `COUNT(column)`은 해당 컬럼이 `NULL`이 아닌 행만 셉니다.

```sql
SELECT COUNT(*) AS total_rentals,
       COUNT(returned_at) AS returned_rentals
FROM rental;
```

### 조건 함수처럼 쓰는 CASE

SQLite에서 조건에 따라 다른 값을 보여주고 싶을 때는 `CASE`를 사용합니다.
엄밀히 말하면 함수라기보다 SQL 표현식이지만, 함수처럼 값을 바꿔 보여줄 때 자주 씁니다.

```sql
SELECT title,
       CASE
           WHEN available_copies = 0 THEN '대여 불가'
           WHEN available_copies <= 2 THEN '수량 적음'
           ELSE '대여 가능'
       END AS availability_status
FROM book;
```

### 타입 확인 함수

SQLite는 타입이 유연하므로 실제 저장된 값의 타입을 확인하고 싶을 때 `typeof()`를 사용할 수 있습니다.

```sql
SELECT title,
       typeof(title) AS title_type,
       typeof(published_year) AS year_type
FROM book;
```

`typeof()` 결과는 보통 `integer`, `real`, `text`, `blob`, `null` 중 하나입니다.

### 과제에서 특히 유용한 함수

이번 과제에서는 아래 함수를 자주 쓰면 좋습니다.

| 상황 | 추천 함수 |
| --- | --- |
| 책 제목 길이 확인 | `length()` |
| 제목 일부만 표시 | `substr()` |
| 전화번호 기호 제거 | `replace()` |
| 반납일이 NULL일 때 문구 표시 | `ifnull()` |
| 평균 대여 기간 계산 | `avg()`, `julianday()`, `round()` |
| 월별 대여 건수 | `strftime()`, `count()` |
| 상태별 건수 | `count()`, `group by` |
| 실제 저장 타입 확인 | `typeof()` |

## 29. 자주 하는 실수

### 외래 키를 켜지 않음

SQLite에서는 다음 설정을 실행하는 습관을 들이는 것이 좋습니다.

```sql
PRAGMA foreign_keys = ON;
```

### UPDATE나 DELETE에 WHERE를 빼먹음

아래 쿼리는 모든 대여 기록을 수정하므로 위험합니다.

```sql
UPDATE rental
SET status = 'RETURNED';
```

수정이나 삭제 전에는 먼저 `SELECT`로 대상 행을 확인하는 것이 안전합니다.

```sql
SELECT *
FROM rental
WHERE id = 2;
```

### NULL을 `=`로 비교함

아래 쿼리는 의도대로 동작하지 않습니다.

```sql
SELECT *
FROM rental
WHERE returned_at = NULL;
```

NULL은 다음처럼 비교해야 합니다.

```sql
SELECT *
FROM rental
WHERE returned_at IS NULL;
```

## 30. 과제에서 최소로 기억할 문법

이번 과제를 제출하기 위해 꼭 기억해야 할 문법은 다음입니다.

```sql
CREATE TABLE
INSERT INTO
SELECT
WHERE
ORDER BY
LIMIT
INNER JOIN
LEFT JOIN
GROUP BY
COUNT
AVG
UPDATE
DELETE
CREATE INDEX
PRAGMA foreign_keys = ON
```

이 문법들을 이해하면 이번 도서 대여 DB 과제의 핵심 요구사항을 모두 설명할 수 있습니다.
