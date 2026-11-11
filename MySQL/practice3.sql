use madang;

# 도서번호가 1인 도서의 이름
select bookname
from book
where bookid = 1
order by bookname;

# 가격이 20000원 이상인 도서의 이름?
select bookname
from book
where price >= 20000
order by bookname;

# 도서의 총 갯수
select count(*)
from book;

# 모든 고객의 이름, 주소 출력
select name, address
from customer;

# 박지성의 총 구매액
select sum(saleprice)
from customer as c
	inner join orders as o
		on o.custid = c.custid
where c.name = '박지성';

# 박지성이 구매한 도서의 수
select count(*)
from orders as o
	inner join customer as c
		on o.custid = c.custid
where c.name = '박지성';

# 박지성이 구매한 도서의 출판사 수
select count(distinct publisher)
from book as b
	inner join orders as o
		on b.bookid = o.bookid
	inner join customer as c
		on o.custid = c.custid
where c.name = '박지성';

# 박지성이 구매한 도서의 이름, 가격, 정가와 판매가격 차이
select bookname, price, price - saleprice
from book as b
	inner join orders as o
		on b.bookid = o.bookid
	inner join customer as c
		on o.custid = c.custid
where c.name = '박지성';

# 주문금액의 총액과 주문금액의 평균 금액 구하기
select sum(saleprice), avg(saleprice)
from orders;

# 고객의 이름과 고객별 구매액
select c.name, sum(o.saleprice)
from customer as c
	inner join orders as o
		on c.custid = o.custid
group by c.custid;

# 고객의 이름과 고객이 구매한 도서 이름을 출력
select c.name, b.bookname
from book as b
	inner join orders as o
		on b.bookid = o.bookid
	inner join customer as c
		on o.custid = c.custid
order by c.name, b.bookname;

# 2014년 7월 4일부터 7월7일 사이에 주문 받은 도서의 주문 번호 출력
select orderid
from orders
where orderdate between '2014-07-04' and '2014-07-07';

# 2014년 7월 4일부터 7월7일 사이에 주문 받은 도서를 제외한 주문 번호 출력
select orderid
from orders
where orderdate not between '2014-07-04' and '2014-07-07';

# 성이 김씨인 고객의 이름과 주소
select name, address
from customer
where name like '김%';

# 성이 김씨이고 이름이 아로 끝나는 고객의 이름과 주소
select name, address
from customer
where name like '김%아';

# 주문하지 않은 고객의 이름
select name
from customer
where name not in(
	select name
	from customer as c
		inner join orders as o
			on o.custid = c.custid
);

