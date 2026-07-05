# SQLite 도서 대여 데이터베이스

이 프로젝트는 SQLite로 만드는 도서 대여 관리 데이터베이스 과제입니다.
백엔드 프레임워크 없이 테이블 설계, 샘플 데이터 입력, 핵심 SQL 쿼리 작성, 실행 결과 확인까지 SQL만으로 진행합니다.

## 1. 과제 개요

- 주제: 도서 대여 관리
- DB: SQLite
- 결과 저장 방식: 쿼리 실행 결과 텍스트 파일
- 핵심 목표: PK/FK, 1:N 관계, JOIN, GROUP BY, 서브쿼리, UPDATE/DELETE, 인덱스를 직접 실습한다.

SQLite를 선택한 이유는 별도 서버 설치 없이 하나의 DB 파일로 SQL을 연습할 수 있기 때문입니다.
이번 과제의 핵심은 서버 운영이 아니라 관계형 데이터베이스의 구조와 SQL 조회 흐름을 이해하는 것입니다.

## 2. 파일 구성

| 파일/폴더 | 역할 |
| --- | --- |
| `schema.sql` | 테이블 구조를 만드는 SQL |
| `seed.sql` | 샘플 데이터를 넣는 SQL |
| `queries.sql` | 과제에서 요구한 핵심 쿼리 모음 |
| `results/query_results.txt` | 쿼리 실행 결과 텍스트 |
| `docs/ERD.md` | 이미지 기반 ERD와 관계 설명 |
| `docs/SQLITE_SYNTAX.md` | SQLite 문법과 과제 참고 개념 정리 |
| `library.db` | 실행 후 생성된 SQLite DB 파일 |
| `docs/subject.md` | 원본 과제 설명 |

## 3. 실행 순서

터미널에서 이 폴더로 이동한 뒤 아래 순서대로 실행합니다.

```bash
sqlite3 library.db < schema.sql
sqlite3 library.db < seed.sql
sqlite3 -header -column library.db < queries.sql > results/query_results.txt
```

실행 흐름은 다음과 같습니다.

1. `schema.sql`로 테이블을 생성합니다.
2. `seed.sql`로 샘플 데이터를 입력합니다.
3. `queries.sql`로 조회, 조인, 집계, 수정, 삭제 쿼리를 실행합니다.
4. 실행 결과를 `results/query_results.txt`에 저장합니다.

처음부터 다시 실행하고 싶다면 `library.db` 파일을 새로 만든 뒤 위 명령을 다시 실행하면 됩니다.

## 4. 데이터 모델 요약

이번 DB는 4개의 도메인 테이블로 구성됩니다.

| 테이블 | 설명 |
| --- | --- |
| `category` | 도서 카테고리 |
| `member` | 도서관 회원 |
| `book` | 도서 정보 |
| `rental` | 회원이 책을 빌린 기록 |

관계는 다음과 같습니다.

- `category` 1 : N `book`
- `member` 1 : N `rental`
- `book` 1 : N `rental`

### 1:N 관계의 실제 의미

`category`와 `book`은 카테고리 하나에 여러 권의 책이 속하는 관계입니다.
예를 들어 `기술` 카테고리에는 `SQL 첫걸음 실습편`, `웹 개발 기본기`가 함께 들어갑니다.
하지만 한 권의 책은 하나의 카테고리에만 속하도록 `book.category_id`로 연결했습니다.

`member`와 `rental`은 회원 한 명이 여러 번 책을 빌릴 수 있는 관계입니다.
예를 들어 `김민준` 회원은 `SQL 첫걸음 실습편`, `웹 개발 기본기`를 빌린 기록을 가지고 있습니다.
회원 정보는 `member`에 한 번만 저장하고, 대여 기록은 `rental.member_id`로 회원을 참조합니다.

`book`과 `rental`은 책 한 권이 시간에 따라 여러 번 대여될 수 있는 관계입니다.
같은 책이 다른 회원에게 반복해서 대여될 수 있기 때문에 책 자체의 정보는 `book`에 두고,
언제 누가 빌렸는지는 `rental`에 따로 저장했습니다.

자세한 ERD는 [docs/ERD.md](docs/ERD.md)에서 확인할 수 있습니다.

## 5. 핵심 쿼리 범위

`queries.sql`에는 총 21개의 쿼리가 들어 있습니다.

| 범위 | 포함 내용 |
| --- | --- |
| 기본 조회 | `WHERE`, `ORDER BY`, `LIMIT` |
| JOIN | `INNER JOIN`, `LEFT JOIN` |
| 집계 | `COUNT`, `AVG`, `GROUP BY` |
| 서브쿼리 | 평균보다 많이 대여한 회원 찾기 |
| 비교 풀이 | 같은 요구를 JOIN과 서브쿼리로 각각 해결 |
| 인덱스 | `CREATE INDEX` |
| 수정/삭제 | `UPDATE`, `DELETE`, `ROLLBACK` |
| 보너스 미니 리포트 | 월별 대여 건수, 인기 도서 TOP 10, 회원별 연체율 |

`UPDATE`와 `DELETE` 예시는 실습 후 원본 데이터가 유지되도록 `ROLLBACK`으로 되돌립니다.

## 6. 쿼리 실행 결과와 해석

전체 실행 결과는 `results/query_results.txt`에 저장했습니다.
아래에는 평가 기준에서 중요한 JOIN, GROUP BY, 서브쿼리 결과를 README에서도 바로 확인할 수 있도록 요약했습니다.

### INNER JOIN과 LEFT JOIN 차이

Q5는 `INNER JOIN`으로 대여 기록에 회원 이름과 책 제목을 붙여 조회합니다.
`INNER JOIN`은 양쪽 테이블에 모두 연결되는 데이터만 보여주기 때문에,
실제 대여 기록이 있는 12건만 결과에 나타납니다.

```text
id  member_name  book_title   rented_at   status
--  -----------  -----------  ----------  --------
1   김민준          SQL 첫걸음 실습편  2026-02-01  RETURNED
2   이서연          달빛 아래 첫 문장   2026-02-03  BORROWED
```

Q8은 `LEFT JOIN`으로 회원별 대여 기록 수를 조회합니다.
왼쪽 테이블인 `member`를 기준으로 조회하기 때문에 대여 기록이 없는 회원도 결과에 포함됩니다.

```text
id  name  rental_count
--  ----  ------------
5   정도윤   0
10  오준서   0
```

즉, `INNER JOIN`은 양쪽에 모두 매칭되는 데이터만 보여주고,
`LEFT JOIN`은 왼쪽 테이블의 데이터를 먼저 유지한 뒤 매칭되는 오른쪽 데이터를 붙입니다.
대여 기록이 없는 회원까지 확인하려면 `LEFT JOIN`이 더 적합합니다.

### GROUP BY와 집계 함수

Q9는 카테고리별 도서 수를 구하기 위해 `category` 기준으로 행을 묶고,
각 그룹에 연결된 `book.id` 개수를 `COUNT`로 계산합니다.

```text
category_name  book_count
-------------  ----------
기술             2
문학             2
경제             1
어린이            0
철학             0
```

`GROUP BY c.id, c.name`은 같은 카테고리에 속한 책들을 하나의 그룹으로 묶습니다.
그리고 `COUNT(b.id)`는 각 그룹 안에서 실제로 연결된 책의 개수를 셉니다.
이 쿼리도 `LEFT JOIN`을 사용했기 때문에 책이 없는 `어린이`, `철학` 카테고리가 0으로 표시됩니다.

Q10은 같은 방식으로 회원별 총 대여 횟수를 집계합니다.
실행 결과에서 `강수아`, `김민준`, `박지호`, `이서연`은 각각 2번 대여한 회원으로 나타납니다.

## 7. 컬럼 타입 선택 이유

SQLite는 타입을 유연하게 다루지만, 컬럼의 의미에 맞게 타입을 정하고 제약조건으로 규칙을 보완했습니다.

| 컬럼 유형 | 사용 타입 | 선택 이유 |
| --- | --- | --- |
| `id` | `INTEGER` | 각 행을 구분하는 PK이며, SQLite에서 자동 증가 정수 id로 관리하기 쉽습니다. |
| 이름, 제목, 이메일, 상태값 | `TEXT` | 문자열 데이터이므로 `TEXT`로 저장했습니다. |
| 날짜 | `TEXT` | SQLite에는 엄격한 `DATE` 타입이 없으므로 `YYYY-MM-DD` 형식의 문자열로 저장했습니다. |
| 권수, 출판연도 | `INTEGER` | 계산, 정렬, 범위 비교가 필요한 숫자 값이므로 정수로 저장했습니다. |
| `category_id`, `member_id`, `book_id` | `INTEGER` | 참조 대상 테이블의 PK가 정수이므로 FK도 같은 타입으로 맞췄습니다. |

상태값인 `member.status`, `rental.status`는 `TEXT`로 저장했습니다.
대신 `CHECK` 제약조건을 사용해 `ACTIVE`, `SUSPENDED`, `WITHDRAWN` 또는
`BORROWED`, `RETURNED`, `OVERDUE`처럼 정해진 값만 들어가도록 제한했습니다.

## 8. 인덱스 선택 이유

이 프로젝트에서는 `rental.member_id`에 인덱스를 만들었습니다.

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_id ON rental(member_id);
```

대여 기록은 회원 기준으로 조회하거나 집계하는 일이 많습니다.
예를 들어 특정 회원의 대여 내역을 찾는 Q7, 회원별 대여 횟수를 구하는 Q8과 Q10에서
`rental.member_id`가 JOIN 조건이나 집계 기준으로 사용됩니다.
그래서 이 컬럼에 인덱스를 만들면 회원 기준 검색과 JOIN에 도움이 됩니다.

다만 모든 컬럼에 인덱스를 만들지는 않았습니다.
인덱스는 조회 속도를 높일 수 있지만, 데이터를 추가하거나 수정할 때 인덱스도 함께 관리해야 하므로 비용이 생깁니다.
이번 과제에서는 조회에 자주 쓰이는 FK 컬럼 하나를 선택해 인덱스 예시로 사용했습니다.

## 9. 데이터베이스와 엑셀의 차이

엑셀은 한 시트에 데이터를 직접 입력하고 바로 보기에는 편합니다.
하지만 회원, 책, 대여 기록이 한 표에 섞이면 같은 정보가 여러 번 반복되기 쉽습니다.
예를 들어 대여 기록마다 회원 전화번호와 책 제목을 모두 적으면,
회원 전화번호가 바뀔 때 여러 행을 함께 수정해야 합니다.

관계형 데이터베이스는 데이터를 역할별 테이블로 나눕니다.
회원 정보는 `member`, 책 정보는 `book`, 대여 기록은 `rental`에 저장합니다.
이렇게 나누면 중복을 줄일 수 있고, FK를 통해 존재하지 않는 회원이나 책이 대여 기록에 들어가는 실수를 막을 수 있습니다.

테이블을 나누는 이유는 데이터를 흩어 놓기 위해서가 아니라,
각 데이터가 책임지는 내용을 분명히 하고 필요한 순간에 JOIN으로 다시 연결하기 위해서입니다.

## 10. 가장 복잡했던 쿼리: 평균보다 많이 대여한 회원 찾기

가장 복잡했던 쿼리는 Q13입니다.
이 쿼리는 회원별 대여 횟수를 구한 뒤,
전체 회원의 평균 대여 횟수보다 많이 대여한 회원만 찾습니다.

풀이 과정은 다음과 같습니다.

1. `member`와 `rental`을 `LEFT JOIN`해서 회원별 대여 횟수를 구합니다.
2. 그 결과를 서브쿼리로 한 번 더 감싸서 전체 회원의 평균 대여 횟수를 계산합니다.
3. 바깥 쿼리에서 각 회원의 대여 횟수가 평균보다 큰 경우만 필터링합니다.

실행 결과는 다음과 같습니다.

```text
member_name  rental_count
-----------  ------------
강수아          2
김민준          2
박지호          2
이서연          2
```

이 쿼리가 어려웠던 이유는 `GROUP BY`로 만든 집계 결과를 다시 평균 계산에 사용해야 했기 때문입니다.
처음에는 `COUNT`와 `AVG`를 한 번에 쓰면 된다고 생각하기 쉽지만,
회원별 대여 횟수라는 중간 결과를 먼저 만든 뒤 그 결과를 다시 비교해야 합니다.
그래서 서브쿼리로 단계를 나누어 해결했습니다.

## 11. 미션 수행 중 어려웠던 점과 해결 방법

가장 어려웠던 부분은 테이블을 어떻게 나눌지 결정하는 것이었습니다.
처음에는 책 정보와 대여 정보를 한 테이블에 함께 넣을 수도 있다고 생각했지만,
그렇게 하면 같은 책 제목과 회원 정보가 여러 번 반복되는 문제가 생깁니다.

그래서 책 자체의 정보는 `book`, 회원 정보는 `member`,
실제 대여 이력은 `rental`로 분리했습니다.
그리고 `rental.member_id`, `rental.book_id`를 FK로 연결해
대여 기록이 어떤 회원과 어떤 책에 대한 기록인지 표현했습니다.

또 하나 어려웠던 부분은 `INNER JOIN`과 `LEFT JOIN`의 차이였습니다.
대여 기록이 없는 회원까지 확인하려면 `LEFT JOIN`이 필요하다는 것을
Q8 실행 결과에서 `rental_count = 0`인 회원을 보며 이해했습니다.

## 12. 보너스 미니 리포트

보너스 과제의 "이 DB로 뽑을 수 있는 핵심 지표 3개"는 Q19, Q20, Q21로 정리했습니다.
도서 대여 DB에서 운영자가 확인하면 좋은 지표를 기준으로 골랐습니다.

### 지표 1: 월별 대여 건수

Q19는 `rented_at` 날짜에서 월 단위를 뽑아 월별 대여 건수를 집계합니다.
대여가 어느 달에 얼마나 발생했는지 보는 지표입니다.

```text
rental_month  rental_count
------------  ------------
2026-02       12
```

현재 샘플 데이터는 2026년 2월 대여 기록으로 구성되어 있어 2월에 12건이 조회됩니다.
데이터가 여러 달로 늘어나면 월별 대여 추이를 비교할 수 있습니다.

### 지표 2: 인기 도서 TOP 10

Q20은 도서별 대여 횟수를 세어 많이 빌린 순서로 정렬합니다.
어떤 책이 자주 대여되는지 확인할 수 있어 추가 구매나 추천 도서 선정에 활용할 수 있습니다.

```text
title        category_name  rental_count
-----------  -------------  ------------
SQL 첫걸음 실습편  기술             3
달빛 아래 첫 문장   문학             2
```

샘플 데이터에서는 `SQL 첫걸음 실습편`이 3회로 가장 많이 대여되었습니다.

### 지표 3: 회원별 연체율

Q21은 대여 이력이 있는 회원별로 전체 대여 횟수와 연체 횟수를 구한 뒤,
연체 횟수를 전체 대여 횟수로 나누어 연체율을 계산합니다.

```text
member_name  total_rentals  overdue_count  overdue_rate_percent
-----------  -------------  -------------  --------------------
최하은          1              1              100.0
강수아          2              1              50.0
```

이 지표는 연체가 자주 발생하는 회원을 확인하거나,
반납 안내가 필요한 대상을 찾을 때 사용할 수 있습니다.

## 13. 잘못된 INSERT는 어떻게 되는가?

이 DB는 `NOT NULL`, `UNIQUE`, `FOREIGN KEY`, `CHECK` 제약조건을 사용합니다.
잘못된 데이터가 들어오면 SQLite가 `INSERT` 자체를 거부합니다.

아래 예시는 실제 과제 DB를 망가뜨리지 않도록 테스트 DB나 `:memory:` DB에서 확인하는 것이 좋습니다.

### NOT NULL 위반

`category.name`은 `NOT NULL`이므로 `NULL`을 넣을 수 없습니다.

```sql
INSERT INTO category (name)
VALUES (NULL);
```

예상 결과:

```text
NOT NULL constraint failed: category.name
```

### UNIQUE 위반

`category.name`은 `UNIQUE`이므로 같은 카테고리 이름을 중복 입력할 수 없습니다.

```sql
INSERT INTO category (name)
VALUES ('문학');

INSERT INTO category (name)
VALUES ('문학');
```

예상 결과:

```text
UNIQUE constraint failed: category.name
```

### FOREIGN KEY 위반

`book.category_id`는 `category.id`를 참조합니다.
존재하지 않는 카테고리 id를 넣으면 실패합니다.

```sql
PRAGMA foreign_keys = ON;

INSERT INTO book (
    category_id, title, author, publisher,
    published_year, isbn, total_copies, available_copies
)
VALUES (
    999, '없는 카테고리 책', '작가', '출판사',
    2026, 'test-isbn', 1, 1
);
```

예상 결과:

```text
FOREIGN KEY constraint failed
```

### CHECK 위반

`member.status`는 `ACTIVE`, `SUSPENDED`, `WITHDRAWN` 중 하나여야 합니다.

```sql
INSERT INTO member (name, email, phone, joined_at, status)
VALUES ('테스트', 'test@example.com', '010-0000-0000', '2026-01-01', 'BLOCKED');
```

예상 결과:

```text
CHECK constraint failed
```

이처럼 제약조건은 잘못된 데이터가 DB에 저장되기 전에 막아주는 안전장치입니다.

## 14. 제출 전 체크리스트

- [x] 테이블이 4개 이상인가?
- [x] 모든 테이블에 PK가 있는가?
- [x] FK를 이용한 1:N 관계가 2개 이상인가?
- [x] `NOT NULL`, `UNIQUE`, `CHECK` 같은 제약조건이 포함되어 있는가?
- [x] 각 테이블에 10행 이상 데이터가 있는가?
- [x] 쿼리가 15개 이상인가?
- [x] 기본 조회, JOIN, 집계, 서브쿼리, UPDATE, DELETE, 인덱스가 모두 포함되어 있는가?
- [x] 각 쿼리에 설명 주석이 있는가?
- [x] 실행 결과가 `results/query_results.txt`에 남아 있는가?
- [x] ERD 문서가 있는가?
- [x] 보너스 미니 리포트 지표 3개가 있는가?

## 15. 참고 문서

- [docs/ERD.md](docs/ERD.md): 테이블 관계와 ERD
- [docs/SQLITE_SYNTAX.md](docs/SQLITE_SYNTAX.md): SQLite 문법 정리
- [docs/subject.md](docs/subject.md): 원본 과제 설명
