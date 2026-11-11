use kiosk;
# ------------------------------
# Case 1) 판매자가 제품을 입력합니다.
# ------------------------------
insert into product
(id, name, size, color, stock, saleprice, insertdate)
values
('nike', '나이키에어', 265, 'white', 50, 100000, now());

insert into product
(id, name, size, color, stock, saleprice, insertdate)
values
('newBalance', '발렌스 블랙', 265, 'white', 40, 150000, now());

insert into product
(id, name, size, color, stock, saleprice, insertdate)
values
('proSpecs', '프로액티브', 265, 'white', 30, 130000, now());

insert into product
(id, name, size, color, stock, saleprice, insertdate)
values
('nike', '나이키에어', 255, 'white', 30, 100000, now());

insert into product
(id, name, size, color, stock, saleprice, insertdate)
values
('newBalance', '발렌스 블랙', 265, 'red', 50, 150000, now());

insert into product
(id, name, size, color, stock, saleprice, insertdate)
values
('proSpecs', '프로액티브', 255, 'red', 30, 130000, now());

# ------------------------------
# Case 2) 고객이 본인의 정보를 입력 합니다.
# ------------------------------
select count(id) from user where id = 'yubee';

insert into user
(id, password, name, phone)
values
('yubee', '1234', '유비', '010-1111-2222');

insert into user
(id, password, name, phone)
values
('jangbee', '2345', '장비', '010-1111-3333');

insert into user
(id, password, name, phone)
values
('kwanwoo', '3456', '관우', '010-1111-4444');

# ------------------------------------
# Case 3) 사용자가 키오스크에 접근하여 본인의 id와 password를 입력하고 신발을 구매하려고 한다.
# ------------------------------------
# 사용자 id : jojo, 암호 : 8989
select count(*) from user 
where id = 'jojo' and password = '8989';

# 사용자 id : yubee, 암호 : 1234
select count(*) from user 
where id = 'yubee' and password = '1234';

# yubee가 nike 제품을 검색하려고 한다.
select *
from product
where id = 'nike' and stock > 0
order by saleprice;

# yubee가 현재일자에 나이키 에어 / Size 265 / color white를 5개 구매

### 구매 정보 입력
insert into purchase
(product_seq, user_id, quantity, purchaseprice, purchasedate)
values
(1, 'yubee', 5, 100000*5, now());

### 제품정보 재고 수정
update product
set stock = stock - 5
where seq = 1;

# yubee가 proSpecs 제품을 검색하고 구매하려고 합니다.

## yubee가 현재 일자에 프로액티브 / size 255 / red를 2개 구매했다.
insert into purchase
(product_seq, user_id, quantity, purchaseprice, purchasedate)
values
(6, 'yubee', 2, 130000*2, now());

update product
set stock = stock - 2
where seq = 6;

# yubee가 newBalance 제품을 검색하고 구매 하려고 한다.

## yubee가 현재 일자에 발랜스 블랙 / size 265 / white를 3개 구매 했다.
insert into purchase
(product_seq, user_id, quantity, purchaseprice, purchasedate)
values
(2, 'yubee', 3, 150000*3, now());

update product
set stock = stock - 3
where seq = 2;


# ------------------------------------------------
# 사용자 id : jangbee, 암호 : 2345
select count(*)
from user
where id = 'jangbee' and password = '2345';
# jangbee가 nike제품을 검색하고 구매하려고 한다.

# jangbee가 현재일자에 나이키에어 / size 265 / white 5개를 구매
insert into purchase
(product_seq, user_id, quantity, purchaseprice, purchasedate)
values
(1,'jangbee',5,100000*5,now());

update product
set stock = stock - 5
where seq = 1;
# jangbee가 newBalance제품을 검색하고 구매하려고 한다.

# jangbee가 현재일자에 발랜스 블랙 / size 265 / white 3개를 구매
insert into purchase
(product_seq, user_id, quantity, purchaseprice, purchasedate)
values
(2,'jangbee',3,150000*3,now());

update product
set stock = stock - 3
where seq = 2;

# ------------------------------------------------
# 사용자 id : kwanwoo, 암호 : 3456
select count(*)
from user
where id = 'kwanwoo' and password = '3456';
# kwanwoo가 newBalance제품을 검색하고 구매하려고 한다.

# kwanwoo가 현재일자에 발랜스 블랙 / size 265 / white 3개를 구매
insert into purchase
(product_seq, user_id, quantity, purchaseprice, purchasedate)
values
(2,'jangbee',3,150000*3,now());

update product
set stock = stock - 3
where seq = 2;

# 유비가 키오스크에 접근하여 자신의 구매 내역을 보고자 한다.
# 제품명, 사이즈, 구매갯수, 구매일자를 일자별 오름차순으로 보이게 하자.
select name, size, quantity, purchasedate
from product as p
	inner join purchase
		on p.seq = product_seq
where user_id = 'yubee'
order by purchasedate;

# 대표이사가 매출현황을 보고자 한다.
# 일자별 매출 금액 보기
select purchasedate, sum(purchaseprice)
from purchase
group by purchasedate
order by purchasedate;

# 구매금액이 가장 큰 고객별로 해당 고객명과 구매 금액 합을 보기
select u.name, sum(purchaseprice)
from purchase as p
	inner join user as u
		on p.user_id = u.id
group by u.id
order by sum(purchaseprice) desc;

# 제품별 최대 매출액 순으로 보기
select p.name, sum(pc.purchaseprice)
from product as p
	inner join purchase as pc
		on p.seq = pc.product_seq
group by pc.product_seq
order by sum(pc.purchaseprice) desc;
