# Database 만들기
create database education;

# 전체 Database 보기
show databases;

# education database에 Table 생성
# education에 접근
use education;

# education에 있는 Table 보기
show tables;

# 교수 Table 제작
create table prof(
pcode char(4) not null primary key,
pname char(10),
pdept char(12),
pphone char(4)
);

# Table 확인
show tables;

# Table 구성 확인
desc prof;

# Table 변경하기
alter table prof add address char(50);

# 확인
desc prof;

# address - paddress로 변경
alter table prof change address paddress char(50);

# 확인
desc prof;

# Table 이름은 prof -> professor로 변경
alter table prof rename professor;

# 확인
show tables;

# Table 속성
desc professor;

# pphone(4) -> pphone(12)
alter table professor modify pphone char(12);

# 확인
desc professor;

# abc char(5)의 컬럼 추가
alter table professor add abc char(5);

# abc 컬럼을 삭제
alter table professor drop abc;

create table student(
scode char(4) not null primary key,
sname char(10),
sdept char(12),
sphone char(12),
saddress varchar(45)
); 

desc student;