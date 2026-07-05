-- SQLite 도서 대여 데이터베이스 스키마
-- 이 파일은 테이블 구조를 만드는 파일입니다.
-- 실행 예시: sqlite3 library.db < schema.sql

-- SQLite는 연결할 때마다 FK 검사를 켜야 합니다.
-- 이 설정이 켜져 있어야 없는 회원이나 없는 책을 대여 기록에 넣는 실수를 막을 수 있습니다.
PRAGMA foreign_keys = ON;

-- 반복 실행할 때 기존 테이블을 안전하게 지우기 위해 자식 테이블부터 삭제합니다.
DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS category;

-- category: 책의 분야를 저장합니다.
-- name은 카테고리 이름이므로 중복되지 않도록 UNIQUE를 적용했습니다.
CREATE TABLE category (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (date('now'))
);

-- member: 도서관 회원 정보를 저장합니다.
-- email은 회원을 식별하는 중요한 값이라 UNIQUE를 적용했습니다.
CREATE TABLE member (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    joined_at TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
);

-- book: 도서 정보를 저장합니다.
-- category_id는 category 테이블의 id를 참조하는 FK입니다.
-- available_copies는 현재 대여 가능한 권수이며 음수가 될 수 없도록 CHECK를 적용했습니다.
CREATE TABLE book (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    publisher TEXT NOT NULL,
    published_year INTEGER NOT NULL CHECK (published_year BETWEEN 1900 AND 2100),
    isbn TEXT NOT NULL UNIQUE,
    total_copies INTEGER NOT NULL CHECK (total_copies >= 0),
    available_copies INTEGER NOT NULL CHECK (available_copies >= 0),
    FOREIGN KEY (category_id) REFERENCES category(id)
);

-- rental: 어떤 회원이 어떤 책을 언제 빌렸는지 저장합니다.
-- member_id는 member 테이블을, book_id는 book 테이블을 참조합니다.
-- status는 현재 대여 상태를 제한된 값 중 하나로만 저장하게 합니다.
CREATE TABLE rental (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    rented_at TEXT NOT NULL,
    due_at TEXT NOT NULL,
    returned_at TEXT,
    status TEXT NOT NULL DEFAULT 'BORROWED'
        CHECK (status IN ('BORROWED', 'RETURNED', 'OVERDUE')),
    FOREIGN KEY (member_id) REFERENCES member(id),
    FOREIGN KEY (book_id) REFERENCES book(id)
);
