use test;
select * from employee_tbl;

# 알바생이 총몇명인지?
select count(*)
from employee_tbl;

select name, count(*)
from employee_tbl group by name;

# daily_typing_pages가 250, 220, 170인 데이터만 출력
select *
from employee_tbl
where daily_typing_pages = 250 or 
	  daily_typing_pages = 220 or
	  daily_typing_pages = 170;

select *
from employee_tbl
where daily_typing_pages in (250, 220, 170);

# daily_typing_pages가 170 이상 300 이하의 데이터
select *
from employee_tbl
where daily_typing_pages >= 170 and daily_typing_pages <= 300;

select *
from employee_tbl
where daily_typing_pages between 170 and 300;

select * from prospect;
select * from customer;
select * from vendor;

select fname, lname, addr from prospect
union
select first_name, last_name, address from customer
union
select company, "", street from vendor;

select fname, lname, addr from prospect
union all
select first_name, last_name, address from customer
union all
select company, "", street from vendor;

# 중복 데이터 찾기
select c.first_name, p.lname
from customer as c
	inner join prospect as p
    on c.first_name = p.fname;

# table의 data 갯수
select count(*)
from employee_tbl;

# 중복된 값 제거
select count(distinct name)
from employee_tbl;

# Zara의 data 갯수
select count(*)
from employee_tbl
where name = 'Zara';

# 최댓값 (min = 최솟값)
select max(daily_typing_pages)
from employee_tbl;

# 직원별 최댓값
select name, max(daily_typing_pages)
from employee_tbl
group by name;

# 최대 최소 (뒤에 least, max는 이름)
select min(daily_typing_pages) least, max(daily_typing_pages) max
from employee_tbl;

# 직원별 평균값
select name, avg(daily_typing_pages)
from employee_tbl
group by name;

# 직원별 합계, 뒤는 계산값
select name, sum(daily_typing_pages), sum(daily_typing_pages) * 1000 as price
from employee_tbl
group by name;

# 수학 함수
select sqrt(16);
select 10+20;
select rand();

# 절대값
select abs(-2);

# 올림
select ceiling(3.46);

# 내림
select floor(7.55);

# 한자리까지 반올림
select round(7.55, 1);

# 두자리까지 자르기
select truncate(1.23456, 2);

# 합치기
select concat(id, name, workdate)
from employee_tbl;

# 문자열 길이
select char_length("1234");

# 왼쪽 3자리만 출력
select left("123456", 3);

# 왼쪽 공백 삭제
select ltrim('   123');

# 3번 반복해서 출력
select repeat('google', 3);

# 순서를 거꾸로 출력
select reverse('1234');

# 5번부터 끝까지 출력  
select substring("abcdefg", 5);

# 5번부터 글자 수(2) 만큼 출력
select substring("abcdefg", 5, 2);

# 날짜 계산
select adddate('2026-08-24', 30);

# 오늘 날짜
select curdate();
select curtime();

# 요일
select dayname('2026-08-24');
select now();