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
| `ERD.md` | 이미지 기반 ERD와 관계 설명 |
| `SQLITE_SYNTAX.md` | SQLite 문법과 과제 참고 개념 정리 |
| `library.db` | 실행 후 생성된 SQLite DB 파일 |
| `subject.md` | 원본 과제 설명 |

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

자세한 ERD는 [ERD.md](ERD.md)에서 확인할 수 있습니다.

## 5. 핵심 쿼리 범위

`queries.sql`에는 총 18개의 쿼리가 들어 있습니다.

| 범위 | 포함 내용 |
| --- | --- |
| 기본 조회 | `WHERE`, `ORDER BY`, `LIMIT` |
| JOIN | `INNER JOIN`, `LEFT JOIN` |
| 집계 | `COUNT`, `AVG`, `GROUP BY` |
| 서브쿼리 | 평균보다 많이 대여한 회원 찾기 |
| 비교 풀이 | 같은 요구를 JOIN과 서브쿼리로 각각 해결 |
| 인덱스 | `CREATE INDEX` |
| 수정/삭제 | `UPDATE`, `DELETE`, `ROLLBACK` |

`UPDATE`와 `DELETE` 예시는 실습 후 원본 데이터가 유지되도록 `ROLLBACK`으로 되돌립니다.

## 6. 잘못된 INSERT는 어떻게 되는가?

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

## 7. 제출 전 체크리스트

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

## 8. 참고 문서

- [ERD.md](./docs/ERD.md): 테이블 관계와 ERD
- [SQLITE_SYNTAX.md](./docs/SQLITE_SYNTAX.md): SQLite 문법 정리
- [subject.md](./docs/subject.md): 원본 과제 설명
