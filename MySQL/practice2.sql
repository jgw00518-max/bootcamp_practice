# 전체 교수 리스트를 출력
use education;
select * from lecture;

# 이름과 전공만 출력
select pname, pdept
from professor;

# 전체 교수 리스트를 이름 순서(오름차순)로 출력
select *
from professor
order by pname;

# 전체 교수 리스트를 전공기준(오름차순)로 출력
select *
from professor
order by pdept;

# 전체 교수 리스트를 전공기준과 이름기준으로 출력
select *
from professor
order by pdept, pname;

# 국문학과 교수 리스트를 출력
select *
from professor
where pdept = '국문학과';

# 국문학과 교수 리스트를 이름 순서로 출력
select *
from professor
where pdept = '국문학과'
order by pname;

# 국문학과 교수 리스트를 이름 순서로 교수명과 주소만 출력
select pname, paddress
from professor
where pdept = '국문학과'
order by pname;

# 전체 교수리스트를 이름 역순 출력
select *
from professor
order by pname desc;

# 전체 교수가 몇명인지 출력
select count(*)
from professor;

# 전체 교수 중 서울에 사는 사람의 명수는?
select count(pcode) as 명수
from professor
where paddress = '서울';

# MySQL 과목을 강의하는 교수님의 이름, 전화번호, 강의실을 출력
select p.pname, p.pphone, c.croom
from professor as p
	inner join lecture as l
			on p.pcode = l.lpcode
	inner join course as c
			on l.lccode = c.ccode
where c.cname = 'MySQL';

# 김구 교수님이 강의하는 과목명, 강의시간, 강의실을 출력
select c.cname, c.ctime, c.croom
from course as c
	inner join lecture as l
			on c.ccode = l.lccode
	inner join professor as p
			on l.lpcode = p.pcode
where p.pname = '김구';

# 김구 교수님이 강의하는 강의 시간의 합계
select sum(c.ctime)
from course as c
	inner join lecture as l
			on c.ccode = l.lccode
	inner join professor as p
			on l.lpcode = p.pcode
where p.pname = '김구';

# 각 학생이 수강 신청한 과목에 대해서 학생이름, 과목명, 강의실, 강의시간을 이름 순으로
# 정렬하여 출력하기
select s.sname, c.cname, c.croom, c.ctime
from student as s
	inner join register as r
			on s.scode = r.rscode
	inner join course as c
			on r.rccode = c.ccode
order by s.sname;

# 각 학생이 신청한 총 학점을 구하는 검색
select s.sname, s.sdept, sum(c.ctime)
from student as s
	inner join register as r
			on s.scode = r.rscode
	inner join course as c
			on r.rccode = c.ccode
group by s.scode;

# 각 학과별 교수님은 몇 분인지 구하는 검색 문장
select pdept as 학과, count(pcode) as 교수인원
from professor
group by pdept
order by pdept;

# 교수 테이블에서 김구 교수님의 이름을 하은용 교수님으로 변경
select *
from professor
where pname = '김구';

update professor
set pname = '하은용'
where pname = '김구';

select * from professor;

# 지도 테이블의 교수 코드가 p005인 데이터를 p007로 변경

update professor
set pcode = 'p007'
where pcode = 'p005';

select * from advise;

# 강의 시간이 2인 과목들의 강의 시간을 하나 증가 시키고 강의실을 Lab1으로 변경
select *
from course;

update course
set ctime = ctime + 1, croom = 'Lab1'
where ctime = 2;

# 자료 삭제: 국문학과 학생 레코드를 삭제
select * 
from student
where sdept = '국문학과';

delete 
from student
where sdept = '국문학과';

select * from student






