-- SQLite 도서 대여 데이터베이스 핵심 쿼리 모음
-- 이 파일은 schema.sql과 seed.sql 실행 후 실행합니다.
-- 실행 예시: sqlite3 -header -column library.db < queries.sql

PRAGMA foreign_keys = ON;

-- Q1. 전체 도서를 제목순으로 조회합니다. 기본 SELECT와 ORDER BY 예시입니다.
SELECT 'Q1. 전체 도서를 제목순으로 조회' AS query_title;
SELECT id, title, author, publisher, published_year
FROM book
ORDER BY title ASC;

-- Q2. 기술 카테고리 도서만 조회합니다. WHERE 조건 예시입니다.
SELECT 'Q2. 기술 카테고리 도서 조회' AS query_title;
SELECT b.id, b.title, b.author
FROM book b
WHERE b.category_id = 4
ORDER BY b.id;

-- Q3. 현재 대여 가능한 권수가 3권 이상인 책을 조회합니다.
SELECT 'Q3. 대여 가능 권수 3권 이상 도서 조회' AS query_title;
SELECT title, total_copies, available_copies
FROM book
WHERE available_copies >= 3
ORDER BY available_copies DESC;

-- Q4. 최근 대여 기록 5개를 조회합니다. LIMIT 예시입니다.
SELECT 'Q4. 최근 대여 기록 5개 조회' AS query_title;
SELECT id, member_id, book_id, rented_at, status
FROM rental
ORDER BY rented_at DESC
LIMIT 5;

-- Q5. 대여 기록에 회원 이름과 책 제목을 붙여 조회합니다. INNER JOIN 예시입니다.
SELECT 'Q5. 대여 기록 + 회원 + 책 INNER JOIN' AS query_title;
SELECT r.id, m.name AS member_name, b.title AS book_title, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.id
INNER JOIN book b ON r.book_id = b.id
ORDER BY r.id;

-- Q6. 도서와 카테고리를 연결해 조회합니다. INNER JOIN 예시입니다.
SELECT 'Q6. 도서 + 카테고리 INNER JOIN' AS query_title;
SELECT b.title, c.name AS category_name, b.author
FROM book b
INNER JOIN category c ON b.category_id = c.id
ORDER BY c.name, b.title;

-- Q7. 특정 회원의 대여 내역을 조회합니다.
SELECT 'Q7. 김민준 회원의 대여 내역 조회' AS query_title;
SELECT m.name, b.title, r.rented_at, r.due_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.id
INNER JOIN book b ON r.book_id = b.id
WHERE m.name = '김민준'
ORDER BY r.rented_at;

-- Q8. 대여 기록이 없는 회원도 함께 조회합니다. LEFT JOIN 예시입니다.
SELECT 'Q8. 회원별 대여 기록 수 LEFT JOIN' AS query_title;
SELECT m.id, m.name, COUNT(r.id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name
ORDER BY rental_count ASC, m.id;

-- Q9. 카테고리별 도서 수를 집계합니다. COUNT와 GROUP BY 예시입니다.
SELECT 'Q9. 카테고리별 도서 수 집계' AS query_title;
SELECT c.name AS category_name, COUNT(b.id) AS book_count
FROM category c
LEFT JOIN book b ON c.id = b.category_id
GROUP BY c.id, c.name
ORDER BY book_count DESC, c.name;

-- Q10. 회원별 총 대여 횟수를 집계합니다.
SELECT 'Q10. 회원별 총 대여 횟수 집계' AS query_title;
SELECT m.name, COUNT(r.id) AS total_rentals
FROM member m
LEFT JOIN rental r ON m.id = r.member_id
GROUP BY m.id, m.name
ORDER BY total_rentals DESC, m.name;

-- Q11. 대여 상태별 건수를 집계합니다.
SELECT 'Q11. 대여 상태별 건수 집계' AS query_title;
SELECT status, COUNT(*) AS status_count
FROM rental
GROUP BY status
ORDER BY status_count DESC;

-- Q12. 반납된 대여 기록의 평균 대여 기간을 계산합니다.
-- SQLite에서는 날짜 차이를 구할 때 julianday 함수를 사용할 수 있습니다.
SELECT 'Q12. 반납된 기록의 평균 대여 기간 계산' AS query_title;
SELECT ROUND(AVG(julianday(returned_at) - julianday(rented_at)), 1) AS avg_rental_days
FROM rental
WHERE returned_at IS NOT NULL;

-- Q13. 평균 대여 횟수보다 많이 대여한 회원을 찾습니다. 서브쿼리 예시입니다.
SELECT 'Q13. 평균보다 많이 대여한 회원 서브쿼리' AS query_title;
SELECT member_name, rental_count
FROM (
    SELECT m.name AS member_name, COUNT(r.id) AS rental_count
    FROM member m
    LEFT JOIN rental r ON m.id = r.member_id
    GROUP BY m.id, m.name
) member_rentals
WHERE rental_count > (
    SELECT AVG(rental_count)
    FROM (
        SELECT COUNT(r.id) AS rental_count
        FROM member m
        LEFT JOIN rental r ON m.id = r.member_id
        GROUP BY m.id
    )
)
ORDER BY rental_count DESC, member_name;

-- Q14. 같은 요구를 JOIN 방식으로 해결합니다. 기술 카테고리 도서 목록입니다.
SELECT 'Q14. 기술 카테고리 도서 조회 JOIN 방식' AS query_title;
SELECT b.title, b.author
FROM book b
INNER JOIN category c ON b.category_id = c.id
WHERE c.name = '기술'
ORDER BY b.title;

-- Q15. 같은 요구를 서브쿼리 방식으로 해결합니다. Q14와 비교할 수 있습니다.
SELECT 'Q15. 기술 카테고리 도서 조회 서브쿼리 방식' AS query_title;
SELECT title, author
FROM book
WHERE category_id = (
    SELECT id
    FROM category
    WHERE name = '기술'
)
ORDER BY title;

-- Q16. 회원별 대여 내역 조회가 많으므로 rental.member_id에 인덱스를 만듭니다.
-- FK 컬럼은 JOIN과 WHERE 조건에 자주 사용되므로 인덱스를 만들면 조회 성능에 도움이 됩니다.
SELECT 'Q16. 회원별 대여 조회를 위한 인덱스 생성' AS query_title;
CREATE INDEX IF NOT EXISTS idx_rental_member_id ON rental(member_id);
SELECT name, tbl_name, sql
FROM sqlite_master
WHERE type = 'index' AND name = 'idx_rental_member_id';

-- Q17. 반납 처리를 UPDATE로 실습합니다.
-- 과제 실습용이므로 ROLLBACK으로 되돌려 실제 샘플 데이터는 보존합니다.
SELECT 'Q17. UPDATE로 반납 처리 실습 후 ROLLBACK' AS query_title;
BEGIN;
UPDATE rental
SET status = 'RETURNED',
    returned_at = '2026-02-16'
WHERE id = 2;
SELECT id, returned_at, status
FROM rental
WHERE id = 2;
ROLLBACK;

-- Q18. 대여 기록 삭제를 DELETE로 실습합니다.
-- 과제 실습용이므로 ROLLBACK으로 되돌려 실제 샘플 데이터는 보존합니다.
SELECT 'Q18. DELETE로 대여 기록 삭제 실습 후 ROLLBACK' AS query_title;
BEGIN;
DELETE FROM rental
WHERE id = 12;
SELECT COUNT(*) AS remaining_rental_count
FROM rental;
ROLLBACK;

-- Q19. 미니 리포트 1: 월별 대여 건수 추이를 확인합니다.
SELECT 'Q19. 미니 리포트 - 월별 대여 건수' AS query_title;
SELECT strftime('%Y-%m', rented_at) AS rental_month,
       COUNT(*) AS rental_count
FROM rental
GROUP BY strftime('%Y-%m', rented_at)
ORDER BY rental_month;

-- Q20. 미니 리포트 2: 가장 많이 대여된 인기 도서 TOP 10을 확인합니다.
SELECT 'Q20. 미니 리포트 - 인기 도서 TOP 10' AS query_title;
SELECT b.title,
       c.name AS category_name,
       COUNT(r.id) AS rental_count
FROM book b
INNER JOIN category c ON b.category_id = c.id
LEFT JOIN rental r ON b.id = r.book_id
GROUP BY b.id, b.title, c.name
ORDER BY rental_count DESC, b.title
LIMIT 10;

-- Q21. 미니 리포트 3: 대여 이력이 있는 회원별 연체율을 확인합니다.
SELECT 'Q21. 미니 리포트 - 회원별 연체율' AS query_title;
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
