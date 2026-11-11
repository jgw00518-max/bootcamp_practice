#--------------------------------------------------------------------------------------------
# 학교에서 장학금 대상자를 선정하려고 한다. 각 학생의 이름, 학과, 수강 과목명, 점수를 조회하고 점수가 높은 순서대로 출력하시오.
select s.sname, s.sdept, c.cname, r.score
from student as s
    inner join register as r
        on s.scode = r.rscode
    inner join course as c
        on r.rccode = c.ccode
order by r.score desc;

# 컴퓨터공학과 교수님들의 총 강의시간을 계산해서 출력
select p.pname, sum(c.ctime) as 총강의시간
from professor as p
   inner join lecture as l
         on p.pcode = l.lpcode
   inner join course as c
         on l.lccode = c.ccode
where p.pdept = '컴퓨터공학과'
group by p.pcode
order by 총강의시간 desc;

# 각 학과별 교수의 이름과 총 강의시간을 구하시오. 
select p.pdept as 학과명, p.pname as 교수명, sum(c.ctime) as 총강의시간 
from professor as p 
          inner join lecture as l 
             on p.pcode = l.lpcode 
          inner join course as c 
             on l.lccode = c.ccode  
group by p.pdept, p.pname ;

# 3학점인 과목을 담당하는 교수의 이름, 담당 과목명을 과목 이름 순으로 출력
select p.pname, c.cname
from professor as p
   inner join lecture as l
      on p.pcode = l.lpcode
   inner join course as c
      on l.lccode = c.ccode
where c.ctime = 3
order by c.cname;
#--------------------------------------------------------------