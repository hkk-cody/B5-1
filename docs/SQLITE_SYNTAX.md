# SQLite SQL 문법 정리

이 문서는 SQLite를 처음 사용하는 사람이 도서 대여 DB 과제를 진행할 때 참고할 수 있도록 정리한 문서입니다.
예시는 현재 과제의 `category`, `member`, `book`, `rental` 테이블을 기준으로 작성했습니다.

섹션 제목의 표시는 다음 뜻입니다.

- `[필수]`: 과제 제출을 위해 꼭 알아야 하는 내용
- `[추가]`: 알면 좋지만, 과제 필수 조건을 넘는 보조 내용

## 1. 문서 읽는 순서 [필수]

처음부터 모두 외우려고 하지 말고 아래 순서로 보면 좋습니다.

1. 데이터베이스 기본 개념을 이해합니다.
2. SQLite 실행 방법을 확인합니다.
3. 테이블, 타입, 제약조건을 이해합니다.
4. 데이터 추가, 조회, 수정, 삭제 문법을 익힙니다.
5. JOIN, GROUP BY, 서브쿼리, 인덱스를 차례로 봅니다.
6. 함수와 자주 하는 실수는 필요할 때 찾아봅니다.

## 2. 데이터베이스 기본 개념 [필수]

데이터베이스는 데이터를 정해진 구조와 규칙에 따라 저장하고 조회하는 시스템입니다.
엑셀처럼 표 형태로 볼 수 있지만, 테이블 사이의 관계와 데이터 규칙을 더 엄격하게 관리할 수 있습니다.

| 개념 | 의미 | 과제 예시 |
| --- | --- | --- |
| DB | 데이터베이스 자체 | `library.db` |
| DBMS | DB를 관리하는 프로그램 | SQLite, MySQL, PostgreSQL |
| 테이블 | 같은 종류의 데이터를 담는 표 | `member`, `book` |
| 행 | 실제 데이터 1건 | 회원 1명, 책 1권 |
| 컬럼 | 데이터의 항목 | `name`, `title`, `rented_at` |
| 스키마 | DB 구조 설계도 | `schema.sql` |
| 쿼리 | DB에 보내는 SQL 요청 | `SELECT * FROM book;` |

### PK와 FK

`PK`는 Primary Key이며, 각 행을 구분하는 고유한 값입니다.
회원 이름은 같을 수 있지만 `member.id`는 중복되면 안 됩니다.

```sql
id INTEGER PRIMARY KEY AUTOINCREMENT
```

`FK`는 Foreign Key이며, 다른 테이블의 PK를 참조하는 값입니다.
대여 기록의 `member_id`는 어떤 회원이 책을 빌렸는지 나타냅니다.

```sql
member_id INTEGER NOT NULL,
FOREIGN KEY (member_id) REFERENCES member(id)
```

SQLite에서는 FK 검사를 켜는 것이 안전합니다.

```sql
PRAGMA foreign_keys = ON;
```

### 1:N 관계

1:N 관계는 한쪽 데이터 1개가 다른 쪽 데이터 여러 개와 연결되는 관계입니다.

| 관계 | 의미 |
| --- | --- |
| `category` 1 : N `book` | 카테고리 하나에 여러 책이 속함 |
| `member` 1 : N `rental` | 회원 한 명이 여러 번 대여함 |
| `book` 1 : N `rental` | 책 한 권이 여러 번 대여될 수 있음 |

이 관계를 잘 설계해야 JOIN으로 연결된 데이터를 자연스럽게 조회할 수 있습니다.

### CRUD

CRUD는 데이터를 다루는 기본 행동 4가지입니다.

| 이름 | SQL | 의미 |
| --- | --- | --- |
| Create | `INSERT` | 데이터 추가 |
| Read | `SELECT` | 데이터 조회 |
| Update | `UPDATE` | 데이터 수정 |
| Delete | `DELETE` | 데이터 삭제 |

### 정규화

정규화는 데이터를 역할에 맞게 여러 테이블로 나누는 설계 방식입니다.
같은 정보를 계속 반복해서 저장하지 않고, 필요한 곳에서 FK로 연결합니다.

예를 들어 대여 기록마다 회원 이름과 이메일을 직접 저장하면 회원 정보가 바뀔 때 모든 대여 기록을 수정해야 합니다.
대신 `member` 테이블에 회원 정보를 한 번만 저장하고, `rental.member_id`로 연결하면 더 안전합니다.

이번 과제에서는 정규화를 깊게 파기보다는 "회원, 책, 카테고리, 대여 기록을 역할별로 나눈다" 정도를 이해하면 충분합니다.

### 엑셀과 데이터베이스의 차이

엑셀도 표 형태로 데이터를 관리할 수 있지만, 관계형 데이터베이스와 목적이 조금 다릅니다.

| 비교 항목 | 엑셀 | 관계형 데이터베이스 |
| --- | --- | --- |
| 데이터 저장 방식 | 한 시트에 직접 입력하는 경우가 많음 | 역할별 테이블로 나누어 저장 |
| 중복 관리 | 같은 값이 여러 행에 반복되기 쉬움 | FK로 연결해 중복을 줄임 |
| 데이터 규칙 | 사용자가 직접 조심해야 함 | PK, FK, CHECK 같은 제약조건으로 막음 |
| 연결 조회 | 사람이 직접 찾아보는 경우가 많음 | JOIN으로 테이블을 연결해 조회 |
| 대량 데이터 | 커질수록 관리가 어려워짐 | 인덱스와 쿼리로 관리 가능 |

예를 들어 대여 기록마다 회원 이름, 전화번호, 책 제목, 출판사를 모두 적으면 같은 정보가 계속 반복됩니다.
회원 전화번호가 바뀌면 여러 행을 찾아 수정해야 하고, 일부 행만 수정되면 데이터가 서로 달라질 수 있습니다.

관계형 데이터베이스에서는 회원 정보는 `member`, 책 정보는 `book`, 대여 기록은 `rental`에 나누어 저장합니다.
그리고 `rental.member_id`, `rental.book_id` 같은 FK로 필요한 순간에 연결합니다.
이 방식은 처음에는 테이블이 많아 보여도 중복과 수정 오류를 줄이는 데 도움이 됩니다.

## 3. SQLite 실행과 CLI 명령 [필수]

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

SQLite CLI에서 자주 쓰는 명령은 다음과 같습니다.

```sql
.tables              -- 테이블 목록 보기
.schema book         -- book 테이블 구조 보기
.headers on          -- 결과에 컬럼명 표시
.mode column         -- 결과를 컬럼 형태로 보기
.mode box            -- 결과를 박스 형태로 보기
.quit                -- SQLite 종료
```

DB 구조를 확인할 때는 아래 명령도 유용합니다.

```sql
PRAGMA table_info(book);          -- book 테이블의 컬럼 정보
PRAGMA foreign_key_list(rental);  -- rental 테이블의 FK 정보
PRAGMA index_list(book);          -- book 테이블의 인덱스 목록
```

SQLite 내부 테이블인 `sqlite_master`를 조회해도 테이블과 인덱스 생성 SQL을 확인할 수 있습니다.

```sql
SELECT type, name, sql
FROM sqlite_master
WHERE type IN ('table', 'index')
ORDER BY type, name;
```

## 4. 테이블 생성, 변경, 삭제 [필수]

테이블은 `CREATE TABLE`로 만듭니다.

```sql
CREATE TABLE member (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    joined_at TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
);
```

테이블을 삭제할 때는 `DROP TABLE`을 사용합니다.

```sql
DROP TABLE IF EXISTS rental;
```

FK 관계가 있으면 자식 테이블을 먼저 삭제하는 것이 안전합니다.
이번 과제에서는 `rental`이 `member`, `book`을 참조하므로 `rental`을 먼저 삭제합니다.

```sql
DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS category;
```

### 이름 작성 습관

테이블명과 컬럼명은 역할이 드러나게 작성하는 것이 좋습니다.

| 좋은 예 | 피하면 좋은 예 | 이유 |
| --- | --- | --- |
| `member` | `m1` | 의미가 바로 보임 |
| `rental` | `data` | 어떤 데이터인지 알 수 있음 |
| `rented_at` | `date1` | 날짜의 역할이 드러남 |
| `available_copies` | `cnt` | 어떤 개수인지 알 수 있음 |

과제에서는 영어 소문자와 밑줄을 사용하는 `snake_case`를 추천합니다.

```sql
member_id
available_copies
created_at
```

SQL 예약어와 겹치는 이름은 피하는 것이 좋습니다.
예를 들어 `order`, `group`, `index` 같은 이름은 문법과 헷갈릴 수 있습니다.

### SQL 주석

SQL에서는 `--`로 한 줄 주석을 작성합니다.

```sql
-- 대여 기록에 회원과 책을 연결해 조회한다.
SELECT r.id, m.name, b.title
FROM rental r
INNER JOIN member m ON r.member_id = m.id
INNER JOIN book b ON r.book_id = b.id;
```

여러 줄 주석은 `/* */`를 사용할 수 있습니다.

```sql
/*
  이 쿼리는 회원별 대여 횟수를 집계한다.
  대여 기록이 없는 회원도 보여주기 위해 LEFT JOIN을 사용한다.
*/
SELECT m.name, COUNT(r.id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name;
```

과제에서는 각 핵심 쿼리 위에 "무엇을 확인하는 쿼리인지" 한 줄 주석을 붙이면 좋습니다.

### 테이블 변경 [추가]

이미 만든 테이블에 컬럼을 추가할 때는 `ALTER TABLE`을 사용합니다.

```sql
ALTER TABLE member
ADD COLUMN memo TEXT;
```

테이블 이름을 바꿀 수도 있습니다.

```sql
ALTER TABLE member
RENAME TO library_member;
```

SQLite의 `ALTER TABLE`은 다른 DB보다 단순한 편입니다.
복잡한 컬럼 변경이 필요하면 새 테이블을 만들고 데이터를 옮기는 방식이 더 안전할 때가 많습니다.

## 5. SQLite 데이터 타입 [필수]

SQLite는 타입을 비교적 유연하게 다룹니다.
그래도 컬럼의 의미에 맞는 타입을 쓰고, 필요한 규칙은 제약조건으로 보완하는 것이 좋습니다.

| 타입 | 설명 | 과제 예시 |
| --- | --- | --- |
| `INTEGER` | 정수 | `id`, `published_year`, `total_copies` |
| `TEXT` | 문자열 | `name`, `title`, `email`, 날짜 문자열 |
| `REAL` | 실수 | 평균, 비율, 소수점 계산값 |
| `BLOB` | 바이너리 데이터 | 이미지, 파일 |
| `NUMERIC` | 숫자처럼 비교 가능한 값 | 날짜, 참/거짓, 정밀 숫자 |

### 타입 선호도 [추가]

SQLite는 선언된 타입 이름을 보고 내부적으로 타입 선호도를 정합니다.

| 타입 선호도 | 대표 선언 예시 | 주로 쓰는 상황 |
| --- | --- | --- |
| `INTEGER` | `INTEGER`, `INT` | 기본 키, 수량, 연도 |
| `TEXT` | `TEXT`, `VARCHAR(100)` | 이름, 제목, 설명 |
| `REAL` | `REAL`, `DOUBLE`, `FLOAT` | 평균, 비율 |
| `NUMERIC` | `NUMERIC`, `DECIMAL`, `BOOLEAN`, `DATE` | 날짜, 참/거짓, 정밀 숫자 |
| `BLOB` | `BLOB` | 파일, 이미지 |

SQLite는 MySQL이나 PostgreSQL처럼 타입을 아주 엄격하게 강제하지 않습니다.
예를 들어 `VARCHAR(100)`이라고 써도 길이 100자를 자동으로 막지 않습니다.

길이를 제한하려면 `CHECK`를 사용합니다.

```sql
name TEXT NOT NULL CHECK (length(name) <= 10)
```

### 문자열 타입

SQLite에서 문자열은 사실상 `TEXT`를 기본으로 생각하면 됩니다.

| 선언 예시 | SQLite에서의 취급 |
| --- | --- |
| `TEXT` | 문자열 |
| `VARCHAR(100)` | 문자열, 길이 제한 자동 적용 안 됨 |
| `CHAR(10)` | 문자열, 고정 길이 자동 적용 안 됨 |
| `CLOB` | 긴 문자열 |
| `NCHAR`, `NVARCHAR` | 문자열 |

과제에서는 아래처럼 `TEXT`를 쓰면 충분합니다.

```sql
title TEXT NOT NULL,
email TEXT NOT NULL UNIQUE,
status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
```

### 날짜와 시간

SQLite에는 엄격한 `DATE` 타입이 없습니다.
과제 수준에서는 날짜를 `TEXT`로 저장하고 `YYYY-MM-DD` 형식을 사용하면 좋습니다.

```sql
joined_at TEXT NOT NULL
```

`YYYY-MM-DD` 형식은 문자열 정렬을 해도 날짜 순서가 잘 맞습니다.

```sql
SELECT name, joined_at
FROM member
ORDER BY joined_at DESC;
```

### 참/거짓 값 [추가]

SQLite에는 엄격한 `BOOLEAN` 타입이 없습니다.
보통 `0`, `1`을 쓰거나 상태 문자열을 사용합니다.

```sql
is_active INTEGER NOT NULL CHECK (is_active IN (0, 1))
```

```sql
status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
```

### 돈과 소수 [추가]

금액처럼 정확해야 하는 값은 `REAL`보다 정수 단위로 저장하는 것이 안전합니다.

```sql
price_won INTEGER NOT NULL CHECK (price_won >= 0)
```

평균 대여 기간처럼 약간의 소수점 오차가 큰 문제가 아닌 값은 `REAL` 계산을 사용해도 괜찮습니다.

### 이번 과제에서 타입을 고른 기준

과제에서 타입을 설명할 때는 "무슨 값을 저장하는지"와 "어떤 연산을 할지"를 함께 말하면 좋습니다.

| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| `category.id`, `member.id`, `book.id`, `rental.id` | `INTEGER` | 각 행을 구분하는 PK이며 자동 증가 숫자로 관리하기 좋음 |
| `name`, `title`, `author`, `publisher`, `email`, `phone` | `TEXT` | 문자 그대로 저장하고 보여주는 값 |
| `joined_at`, `rented_at`, `due_at`, `returned_at` | `TEXT` | SQLite에는 엄격한 DATE 타입이 없으므로 `YYYY-MM-DD` 문자열로 저장 |
| `published_year`, `total_copies`, `available_copies` | `INTEGER` | 정렬, 비교, 계산이 필요한 숫자 |
| `category_id`, `member_id`, `book_id` | `INTEGER` | 참조 대상 PK가 정수이므로 FK도 정수로 맞춤 |
| `status` | `TEXT` | 상태 이름을 읽기 쉽게 저장하되 `CHECK`로 허용 값을 제한 |

날짜를 `TEXT`로 저장할 때는 `2026-02-01`처럼 `YYYY-MM-DD` 형식을 맞추는 것이 중요합니다.
이 형식은 문자열 정렬을 해도 날짜 순서와 같은 방향으로 정렬됩니다.

```sql
SELECT id, rented_at
FROM rental
ORDER BY rented_at DESC;
```

## 6. 제약조건 [필수]

제약조건은 잘못된 데이터가 들어오지 않도록 막는 규칙입니다.

| 제약조건 | 의미 |
| --- | --- |
| `PRIMARY KEY` | 행을 구분하는 기본 키 |
| `AUTOINCREMENT` | 숫자 PK를 자동 증가 |
| `NOT NULL` | 빈 값 저장 금지 |
| `UNIQUE` | 중복 값 저장 금지 |
| `CHECK` | 조건에 맞는 값만 저장 |
| `DEFAULT` | 값을 생략했을 때 기본값 사용 |
| `FOREIGN KEY` | 다른 테이블의 PK 참조 |

예시는 다음과 같습니다.

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

## 7. 데이터 추가 [필수]

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

FK가 있는 테이블은 참조 대상 데이터가 먼저 있어야 합니다.
예를 들어 `book.category_id`는 `category.id`를 참조하므로 카테고리를 먼저 넣어야 합니다.

## 8. 기본 조회 [필수]

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

컬럼 이름을 보기 좋게 바꾸려면 `AS`를 사용합니다.

```sql
SELECT title AS book_title,
       author AS book_author
FROM book;
```

중복 값을 제거하려면 `DISTINCT`를 사용합니다.

```sql
SELECT DISTINCT status
FROM rental;
```

### SELECT 작성 순서와 처리 순서 [추가]

SQL은 보통 아래 순서로 작성합니다.

```sql
SELECT 컬럼
FROM 테이블
JOIN 연결할_테이블
WHERE 행_조건
GROUP BY 그룹_기준
HAVING 그룹_조건
ORDER BY 정렬_기준
LIMIT 개수;
```

DB가 논리적으로 처리하는 순서는 작성 순서와 조금 다릅니다.

| 처리 순서 | 의미 |
| --- | --- |
| `FROM` | 어떤 테이블에서 시작할지 정함 |
| `JOIN` | 필요한 테이블을 연결함 |
| `WHERE` | 조건에 맞는 행만 남김 |
| `GROUP BY` | 남은 행을 그룹으로 묶음 |
| `HAVING` | 그룹 조건을 적용함 |
| `SELECT` | 보여줄 컬럼을 고름 |
| `ORDER BY` | 결과를 정렬함 |
| `LIMIT` | 결과 개수를 제한함 |

이 순서를 알면 `WHERE`와 `HAVING`의 차이를 이해하기 쉽습니다.

## 9. 조건, 정렬, 제한 [필수]

`WHERE`는 조건에 맞는 데이터만 조회합니다.

```sql
SELECT title, author
FROM book
WHERE category_id = 4;
```

여러 조건은 `AND`, `OR`로 연결합니다.

```sql
SELECT title, author
FROM book
WHERE category_id = 4
  AND available_copies > 0;
```

자주 쓰는 조건 문법은 다음과 같습니다.

| 문법 | 의미 | 예시 |
| --- | --- | --- |
| `=` | 같다 | `status = 'BORROWED'` |
| `!=`, `<>` | 같지 않다 | `status != 'RETURNED'` |
| `>`, `>=`, `<`, `<=` | 크기 비교 | `published_year >= 2020` |
| `IN` | 목록 중 하나 | `status IN ('BORROWED', 'OVERDUE')` |
| `BETWEEN` | 범위 안 | `published_year BETWEEN 2020 AND 2024` |
| `LIKE` | 문자열 패턴 | `title LIKE '%SQL%'` |
| `IS NULL` | NULL인지 확인 | `returned_at IS NULL` |

`IN`은 여러 값 중 하나와 일치하는지 확인할 때 편합니다.

```sql
SELECT id, member_id, book_id, status
FROM rental
WHERE status IN ('BORROWED', 'OVERDUE');
```

`BETWEEN`은 시작값과 끝값을 포함합니다.

```sql
SELECT title, published_year
FROM book
WHERE published_year BETWEEN 2020 AND 2024;
```

조건이 복잡해지면 괄호로 의도를 분명하게 만드는 것이 좋습니다.

```sql
SELECT title, available_copies, published_year
FROM book
WHERE (available_copies > 0 AND published_year >= 2020)
   OR title LIKE '%SQL%';
```

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

## 10. 문자열 검색과 처리 [필수]

`LIKE`는 문자열 일부를 검색할 때 사용합니다.

```sql
SELECT title, author
FROM book
WHERE title LIKE '%SQL%';
```

| 패턴 | 의미 |
| --- | --- |
| `'SQL%'` | SQL로 시작 |
| `'%SQL'` | SQL로 끝남 |
| `'%SQL%'` | SQL을 포함 |
| `'SQL_'` | SQL 뒤에 한 글자가 더 있음 |

SQLite의 기본 `LIKE`는 영어 알파벳 대소문자를 엄격하게 구분하지 않는 경우가 많습니다.
대소문자 구분 검색이 필요하면 `GLOB`를 사용할 수 있습니다.

```sql
SELECT title
FROM book
WHERE title GLOB '*SQL*';
```

문자열 값은 작은따옴표로 감싸는 것이 표준입니다.

```sql
SELECT *
FROM member
WHERE name = '김민준';
```

문자열을 합칠 때는 `||`를 사용합니다.

```sql
SELECT name || ' / ' || email AS member_contact
FROM member;
```

MySQL의 `CONCAT()`과 다르므로 주의합니다.

## 11. NULL 처리 [필수]

`NULL`은 값이 없다는 뜻입니다.
`NULL`은 `=`로 비교하지 않고 `IS NULL` 또는 `IS NOT NULL`을 사용합니다.

```sql
SELECT id, member_id, book_id
FROM rental
WHERE returned_at IS NULL;
```

```sql
SELECT id, returned_at
FROM rental
WHERE returned_at IS NOT NULL;
```

`NULL`일 때 대체 값을 보여주려면 `ifnull()`을 사용할 수 있습니다.

```sql
SELECT id,
       ifnull(returned_at, '아직 반납 안 함') AS return_status
FROM rental;
```

## 12. 데이터 수정과 삭제 [필수]

`UPDATE`는 기존 데이터를 수정합니다.

```sql
UPDATE rental
SET status = 'RETURNED',
    returned_at = '2026-02-16'
WHERE id = 2;
```

`DELETE`는 데이터를 삭제합니다.

```sql
DELETE FROM rental
WHERE id = 12;
```

`UPDATE`와 `DELETE`에서 `WHERE`를 빼면 모든 행이 바뀌거나 삭제될 수 있으므로 매우 조심해야 합니다.

## 13. 트랜잭션 [필수]

트랜잭션은 여러 SQL을 하나의 작업 단위로 묶는 기능입니다.

```sql
BEGIN;

UPDATE rental
SET status = 'RETURNED'
WHERE id = 2;

ROLLBACK;
```

`ROLLBACK`은 변경 내용을 되돌립니다.
실습 중 데이터를 망가뜨리지 않고 `UPDATE`, `DELETE`를 확인할 때 유용합니다.

변경 내용을 확정하려면 `COMMIT`을 사용합니다.

```sql
BEGIN;

UPDATE rental
SET status = 'RETURNED'
WHERE id = 2;

COMMIT;
```

## 14. JOIN [필수]

JOIN은 여러 테이블의 데이터를 연결해서 한 번에 조회하는 문법입니다.

### INNER JOIN

`INNER JOIN`은 양쪽 테이블에 모두 연결되는 데이터만 보여줍니다.

```sql
SELECT r.id, m.name, b.title, r.rented_at
FROM rental r
INNER JOIN member m ON r.member_id = m.id
INNER JOIN book b ON r.book_id = b.id;
```

### LEFT JOIN

`LEFT JOIN`은 왼쪽 테이블의 데이터를 모두 보여주고, 오른쪽에 연결된 데이터가 없으면 `NULL`로 보여줍니다.

```sql
SELECT m.name, COUNT(r.id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name;
```

대여 기록이 없는 회원도 보고 싶을 때 유용합니다.

### JOIN 결과를 해석하는 방법

JOIN은 문법을 아는 것만큼 결과를 보고 차이를 설명하는 것이 중요합니다.

`INNER JOIN`은 연결되는 행만 남깁니다.
이번 과제의 Q5처럼 `rental`을 기준으로 `member`, `book`을 연결하면 실제 대여 기록 12건만 출력됩니다.
대여 기록이 없는 회원은 `rental`에 연결될 행이 없으므로 결과에 나오지 않습니다.

```sql
SELECT r.id, m.name, b.title
FROM rental r
INNER JOIN member m ON r.member_id = m.id
INNER JOIN book b ON r.book_id = b.id;
```

`LEFT JOIN`은 왼쪽 테이블을 먼저 모두 유지합니다.
Q8처럼 `member`를 왼쪽에 두면 대여 기록이 없는 회원도 출력되고, `COUNT(r.id)` 결과가 0으로 나타납니다.

```sql
SELECT m.id, m.name, COUNT(r.id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name;
```

실행 결과에 `rental_count = 0`인 회원이 있다면,
그 회원은 `member`에는 존재하지만 `rental`에는 연결된 대여 기록이 없다는 뜻입니다.

## 15. GROUP BY와 HAVING [필수]

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
| `COUNT(column)` | NULL이 아닌 값 개수 |
| `SUM(column)` | 합계 |
| `AVG(column)` | 평균 |
| `MIN(column)` | 최솟값 |
| `MAX(column)` | 최댓값 |

`WHERE`는 그룹으로 묶기 전 조건이고, `HAVING`은 그룹으로 묶은 뒤 조건입니다.

```sql
SELECT member_id, COUNT(*) AS rental_count
FROM rental
GROUP BY member_id
HAVING COUNT(*) >= 2;
```

### GROUP BY 결과를 해석하는 방법

`GROUP BY`는 여러 행을 기준값별로 묶은 뒤, 각 묶음마다 집계 함수를 적용합니다.
이번 과제의 Q9는 카테고리별 도서 수를 계산합니다.

```sql
SELECT c.name AS category_name, COUNT(b.id) AS book_count
FROM category c
LEFT JOIN book b ON c.id = b.category_id
GROUP BY c.id, c.name
ORDER BY book_count DESC, c.name;
```

이 쿼리에서 `GROUP BY c.id, c.name`은 같은 카테고리에 속한 책들을 한 묶음으로 만듭니다.
그 다음 `COUNT(b.id)`가 각 카테고리에 연결된 책의 개수를 셉니다.
`LEFT JOIN`을 사용했기 때문에 책이 없는 카테고리도 결과에 남고, `COUNT(b.id)`는 0을 반환합니다.

`COUNT(*)`와 `COUNT(column)`은 차이가 있습니다.

| 표현 | 의미 |
| --- | --- |
| `COUNT(*)` | 그룹 안의 전체 행 수를 셈 |
| `COUNT(b.id)` | `b.id`가 NULL이 아닌 행만 셈 |

LEFT JOIN 결과에서 오른쪽 테이블이 연결되지 않으면 `b.id`가 NULL이 됩니다.
그래서 "책이 없는 카테고리의 책 수"를 구할 때는 `COUNT(b.id)`가 더 자연스럽습니다.

## 16. 서브쿼리 [필수]

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

### 복잡한 서브쿼리는 단계로 나누기

서브쿼리가 어려울 때는 한 번에 완성하려고 하지 말고 중간 결과를 먼저 만듭니다.
이번 과제의 Q13은 "평균보다 많이 대여한 회원"을 찾는 쿼리입니다.

1단계는 회원별 대여 횟수를 구하는 것입니다.

```sql
SELECT m.name AS member_name, COUNT(r.id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name;
```

2단계는 이 회원별 대여 횟수들의 평균을 구하는 것입니다.
집계 결과를 다시 집계해야 하므로 서브쿼리로 한 번 감쌉니다.

```sql
SELECT AVG(rental_count)
FROM (
    SELECT COUNT(r.id) AS rental_count
    FROM member m
    LEFT JOIN rental r ON m.id = r.member_id
    GROUP BY m.id
);
```

3단계는 바깥 쿼리에서 `rental_count`가 평균보다 큰 회원만 남기는 것입니다.
복잡한 쿼리는 이렇게 "중간 표를 만든다"는 생각으로 나누면 이해하기 쉽습니다.

## 17. 날짜 함수와 CASE [필수]

SQLite는 날짜를 보통 `TEXT`로 저장하고 날짜 함수로 계산합니다.

```sql
SELECT date('now') AS today;
```

날짜 차이를 계산할 때는 `julianday()`를 사용할 수 있습니다.

```sql
SELECT ROUND(AVG(julianday(returned_at) - julianday(rented_at)), 1) AS avg_rental_days
FROM rental
WHERE returned_at IS NOT NULL;
```

월별 집계에는 `strftime()`이 유용합니다.

```sql
SELECT strftime('%Y-%m', rented_at) AS rental_month,
       COUNT(*) AS rental_count
FROM rental
GROUP BY strftime('%Y-%m', rented_at);
```

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

### 보너스 미니 리포트 쿼리에서 사용한 문법 [추가]

미니 리포트는 단순히 데이터를 조회하는 것을 넘어서,
운영자가 볼 만한 지표를 SQL로 계산하는 연습입니다.
이번 과제에서는 월별 대여 건수, 인기 도서 TOP 10, 회원별 연체율을 만들었습니다.

#### 월별 대여 건수

날짜가 `YYYY-MM-DD` 형식의 `TEXT`로 저장되어 있으면 `strftime('%Y-%m', 날짜컬럼)`으로 월 단위를 뽑을 수 있습니다.

```sql
SELECT strftime('%Y-%m', rented_at) AS rental_month,
       COUNT(*) AS rental_count
FROM rental
GROUP BY strftime('%Y-%m', rented_at)
ORDER BY rental_month;
```

여기서 `GROUP BY strftime('%Y-%m', rented_at)`은 같은 월에 발생한 대여 기록을 하나의 그룹으로 묶습니다.
그 다음 `COUNT(*)`로 월별 대여 건수를 셉니다.

#### 인기 도서 TOP 10

인기 도서는 도서별 대여 횟수를 세고, 대여 횟수가 많은 순서로 정렬한 뒤 `LIMIT`으로 상위 10개만 남기면 됩니다.

```sql
SELECT b.title,
       c.name AS category_name,
       COUNT(r.id) AS rental_count
FROM book b
INNER JOIN category c ON b.category_id = c.id
LEFT JOIN rental r ON b.id = r.book_id
GROUP BY b.id, b.title, c.name
ORDER BY rental_count DESC, b.title
LIMIT 10;
```

이 쿼리에서 `book`과 `category`는 반드시 연결되어야 하므로 `INNER JOIN`을 사용했습니다.
반면 대여 기록이 아직 없는 책도 TOP 10 후보에 포함하려고 `rental`은 `LEFT JOIN`으로 연결했습니다.
그래서 대여 기록이 없는 책은 `COUNT(r.id)`가 0으로 계산됩니다.

#### 회원별 연체율

연체율은 `연체 횟수 / 전체 대여 횟수 * 100`으로 계산합니다.
조건에 맞는 행만 세고 싶을 때는 `CASE`를 집계 함수 안에 넣을 수 있습니다.

```sql
SELECT m.name AS member_name,
       COUNT(r.id) AS total_rentals,
       SUM(CASE WHEN r.status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count,
       ROUND(
           SUM(CASE WHEN r.status = 'OVERDUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(r.id),
           1
       ) AS overdue_rate_percent
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name
HAVING COUNT(r.id) > 0
ORDER BY overdue_rate_percent DESC, total_rentals DESC, m.name;
```

`CASE WHEN r.status = 'OVERDUE' THEN 1 ELSE 0 END`는 연체 기록이면 1, 아니면 0으로 바꿉니다.
`SUM(...)`으로 이 값을 더하면 회원별 연체 횟수가 됩니다.
`100.0`처럼 소수점이 있는 숫자를 곱하면 정수 나눗셈처럼 보이는 결과를 피하고 비율을 소수로 계산할 수 있습니다.
마지막으로 `ROUND(..., 1)`을 사용해 소수점 한 자리까지 표시했습니다.

`HAVING COUNT(r.id) > 0`은 대여 이력이 없는 회원을 연체율 계산에서 제외하기 위한 조건입니다.
대여 횟수가 0이면 연체율을 계산할 때 0으로 나누는 문제가 생길 수 있기 때문입니다.

## 18. 인덱스 [필수]

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

인덱스는 조회를 빠르게 할 수 있지만, 데이터를 추가하거나 수정할 때 관리 비용이 생깁니다.
모든 컬럼에 만드는 것이 아니라 자주 검색되는 컬럼에 만드는 것이 좋습니다.

### 인덱스를 걸 컬럼 고르기

인덱스는 다음과 같은 컬럼에 우선 고려합니다.

| 기준 | 예시 |
| --- | --- |
| JOIN 조건에 자주 사용됨 | `rental.member_id`, `rental.book_id` |
| WHERE 조건에 자주 사용됨 | `rental.status`, `book.category_id` |
| 정렬이나 범위 검색에 자주 사용됨 | `rental.rented_at`, `book.published_year` |
| 값이 충분히 다양함 | 회원 id, 책 id |

이번 과제에서는 `rental.member_id`에 인덱스를 만들었습니다.
회원별 대여 내역 조회와 회원별 대여 횟수 집계에서 자주 쓰이는 FK 컬럼이기 때문입니다.

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_id
ON rental(member_id);
```

반대로 모든 컬럼에 인덱스를 만드는 것은 좋지 않습니다.
인덱스도 별도의 구조이기 때문에 `INSERT`, `UPDATE`, `DELETE`가 일어날 때 함께 갱신되어야 합니다.
따라서 조회에 자주 쓰이는 컬럼부터 필요한 만큼만 만드는 것이 좋습니다.

### 실행 계획 확인 [추가]

`EXPLAIN QUERY PLAN`은 SQLite가 쿼리를 어떻게 실행할지 간단히 보여줍니다.
인덱스를 만들기 전후에 비교하면 인덱스가 도움이 되는지 감을 잡을 수 있습니다.

```sql
EXPLAIN QUERY PLAN
SELECT *
FROM rental
WHERE member_id = 1;
```

결과에 `USING INDEX` 같은 표현이 보이면 해당 조회에서 인덱스를 사용하고 있다는 뜻입니다.
과제에서는 깊게 분석할 필요는 없지만, 인덱스의 목적을 설명할 때 좋은 근거가 됩니다.

## 19. SQLite 함수 모음 [추가]

SQLite 함수는 값을 계산하거나, 문자열을 다듬거나, 날짜를 처리하거나, 여러 행을 집계할 때 사용합니다.

### 문자열 함수

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

```sql
SELECT title,
       length(title) AS title_length,
       substr(title, 1, 5) AS short_title
FROM book;
```

### 숫자 함수

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

### 날짜와 시간 함수

| 함수 | 설명 | 예시 |
| --- | --- | --- |
| `date(value)` | 날짜 반환 | `date('now')` |
| `datetime(value)` | 날짜와 시간 반환 | `datetime('now')` |
| `time(value)` | 시간 반환 | `time('now')` |
| `julianday(value)` | 날짜를 계산 가능한 숫자로 변환 | `julianday(due_at)` |
| `strftime(format, value)` | 원하는 형식으로 날짜 출력 | `strftime('%Y-%m', rented_at)` |

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

| 함수 | 설명 | 예시 |
| --- | --- | --- |
| `ifnull(value, fallback)` | 값이 NULL이면 대체값 사용 | `ifnull(returned_at, '미반납')` |
| `coalesce(a, b, c, ...)` | NULL이 아닌 첫 번째 값 사용 | `coalesce(returned_at, due_at, rented_at)` |
| `nullif(a, b)` | 두 값이 같으면 NULL 반환 | `nullif(status, 'BORROWED')` |

### 타입 확인 함수

SQLite는 타입이 유연하므로 실제 저장된 값의 타입을 확인하고 싶을 때 `typeof()`를 사용할 수 있습니다.

```sql
SELECT title,
       typeof(title) AS title_type,
       typeof(published_year) AS year_type
FROM book;
```

`typeof()` 결과는 보통 `integer`, `real`, `text`, `blob`, `null` 중 하나입니다.

## 20. SQLite와 MySQL의 주요 차이 [추가]

| 내용 | SQLite | MySQL |
| --- | --- | --- |
| 실행 방식 | 파일 DB | 서버 DB |
| 자동 증가 PK | `INTEGER PRIMARY KEY AUTOINCREMENT` | `INT AUTO_INCREMENT PRIMARY KEY` |
| 문자열 타입 | 대부분 `TEXT`처럼 취급 | `CHAR`, `VARCHAR`, `TEXT` 차이가 더 명확 |
| `VARCHAR(100)` 길이 제한 | 자동 강제 안 됨 | 보통 길이 제한 적용 |
| 현재 날짜 | `date('now')` | `CURDATE()` |
| 날짜 차이 | `julianday(a) - julianday(b)` | `DATEDIFF(a, b)` |
| 문자열 합치기 | `a || b` | `CONCAT(a, b)` |
| FK 활성화 | `PRAGMA foreign_keys = ON;` 권장 | InnoDB 기준 기본 동작 |

이번 과제는 SQLite 기준으로 작성되어 있습니다.
MySQL로 옮길 때는 자동 증가 키, 날짜 함수, 문자열 함수 일부를 수정해야 합니다.

## 21. 자주 하는 실수 [추가]

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

### 문자열 길이 제한을 타입만으로 기대함

SQLite에서는 `VARCHAR(10)`이라고 써도 10자 초과를 자동으로 막지 않습니다.
길이를 제한하려면 `CHECK`를 사용합니다.

```sql
name TEXT NOT NULL CHECK (length(name) <= 10)
```

## 22. 과제에서 최소로 기억할 문법 [필수]

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
HAVING
COUNT
SUM
AVG
CASE
ROUND
UPDATE
DELETE
BEGIN
ROLLBACK
CREATE INDEX
PRAGMA foreign_keys = ON
```

추가로 알면 좋은 문법과 명령은 다음입니다.

```sql
ALTER TABLE
IN
BETWEEN
strftime
EXPLAIN QUERY PLAN
PRAGMA table_info(table_name)
PRAGMA foreign_key_list(table_name)
```

이 문법들을 이해하면 도서 대여 DB 과제의 핵심 요구사항을 설명할 수 있습니다.

## 23. README에 설명할 때 확인할 내용 [추가]

SQL 파일을 작성하는 것과 별개로, 과제 문서에는 실행 결과와 설계 이유가 드러나야 합니다.
README를 점검할 때는 아래 질문에 답할 수 있는지 확인합니다.

- 테이블을 왜 `category`, `member`, `book`, `rental`로 나눴는가?
- 각 1:N 관계가 실제 도서관 업무에서 어떤 의미인가?
- `INTEGER`, `TEXT` 같은 타입을 왜 선택했는가?
- 어떤 컬럼에 인덱스를 만들었고, 왜 그 컬럼을 골랐는가?
- `INNER JOIN`과 `LEFT JOIN`의 결과 차이를 실제 출력으로 설명했는가?
- `GROUP BY`와 `COUNT`, `AVG`가 어떤 단위로 계산되는지 결과를 보고 설명했는가?
- 가장 복잡했던 쿼리를 단계별로 풀어 설명했는가?
- 보너스 미니 리포트의 핵심 지표 3개를 정의하고, 각각을 구하는 SQL을 작성했는가?
- 어려웠던 점과 해결 방법을 본인 DB 구조 기준으로 작성했는가?

이 질문에 답할 수 있으면 SQL을 작성한 것뿐 아니라, 왜 그렇게 설계하고 조회했는지도 설명할 수 있습니다.
