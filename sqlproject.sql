create database library
on
(name=library,
filename='d:\db\library_data.mdf',
size=10MB,
filegrowth=1MB,
maxsize=30MB)
log on
(
name=library_log,
filename='d:\db\library_log.ldf',
size=3MB,
filegrowth=1%,
maxsize=10MB)
use library
go
--drop table reader
--go
create table reader--
(
readerID	int	not null primary key identity(1,1)	,--	
readerName	varchar(8) not null,--
sex	char(2)	check (sex in ('','')),--
grade	char(4) default(str(year(getdate()))),--
department	varchar(20)	not null ,--
Tele	varchar(20)	,--
BorrowNum	int	default(0)	,--0
readerType	Char(4) default('') check (readerType in ('',''))) --
go
--drop table book
--go
create table book--
(
bookID	int	not null primary key identity(1,1),--
bookName	varchar(50) not null ,--
author	varchar(50),--
Price	decimal(5,2),--
bookType	varchar(20),--
KuCunLiang	Int default(10)	,--	
publisher	varchar(50)	--
)
go
--drop table borrow
--go
create table borrow--
(
readerID int not null foreign key references	reader(readerID),--
bookID	int	 not null foreign key references book(bookID),--
borrowerDate datetime default(getdate()),--
returnDate	datetime  --
primary key(readerID,bookID)
)
drop proc p_book_in
go
create proc p_book_in --
@bookName varchar(50),
@author varchar(50),
@Price decimal(5,2),
@bookType varchar(20),
@KuCunLiang	Int,
@publisher varchar(50)
as 
Begin
  set nocount on
  insert into book(bookName,author,Price,bookType,KuCunLiang,publisher) 
         values(@bookName,@author,@Price,@bookType,@KuCunLiang,@publisher)
End
--
exec p_book_in '','',30.2,'',5,''
exec p_book_in '','',33.2,'',5,''
exec p_book_in '','',11.2,'',5,'dddd'


--
drop proc p_reader_in 
go
create proc p_reader_in   --
@readerName	varchar(8),--
@sex	char(2)	,      --
@grade	char(4) ,       --
@department	varchar(20),--
@Tele	varchar(20)	,   --
@BorrowNum	int	,       --
@readerType	Char(4),    --
@mess varchar(50) output--
as
Begin
  set nocount on
  if @readerType not in ('','')
    set @mess=''
  else
    if @sex not in ('','')
       set @mess=''  
    else
    begin
       insert into reader(readerName,sex,grade,department,Tele,BorrowNum,readerType)
       values(@readerName,@sex,@grade,@department,@Tele,@BorrowNum,@readerType) 
       if @@ERROR!=0
         set @mess=''
       else
         Set  @mess=@readerName+''       
    end   
end

--
declare @ms varchar(50)
exec  p_reader_in '','dd','2016','',12333,0,'',@ms output
print @ms

declare @ms varchar(50)
exec  p_reader_in '','','2016','',12333,0,'gg',@ms output
print @ms

declare @ms varchar(50)
exec  p_reader_in '','','2016','',12333,0,'',@ms output
print @ms
exec  p_reader_in '','','2011','',156,0,'',@ms output
print @ms
exec  p_reader_in '','','2000','',12333,0,'',@ms output
print @ms
exec  p_reader_in '','','2016','',12333,0,'',@ms output
print @ms

--
drop trigger tr_borrow_in
go
create trigger tr_borrow_in --
--readerbook
on borrow
after insert
as
begin
  update reader set BorrowNum=BorrowNum+1 where readerid in (select readerid from inserted)
  update book set KuCunLiang=KuCunLiang-1 where bookid in (select bookid from inserted)
end
go

drop trigger tr_borrow_up
go
create trigger tr_borrow_up --
--readerbook
on borrow
after update
as
begin
  update reader set BorrowNum=BorrowNum-1 where readerid in (select readerid from inserted)
  update book set KuCunLiang=KuCunLiang+1 where bookid in (select bookid from inserted)  
end
Go


drop PROCEDURE p_jieshu
go
CREATE PROCEDURE p_jieshu @readerID int,@bookID int,@ts varchar(50) output
AS
BEGIN
  set nocount on
  declare @sl int,@BorrowNum int,@KuCunLiang int
  select @sl=COUNT(*) from Book where bookid=@bookID
  if @sl=0
  begin
    set @ts=''
    return
  end
  select @sl=COUNT(*) from reader where readerid=@readerID
  if @sl=0
  begin
    set @ts=''
    return
  end  
  select @KuCunLiang=KuCunLiang from book where bookID=@bookID
  if @KuCunLiang<=0
  begin
    set @ts=@ts+''
    return
  end
  begin try
	INSERT INTO borrow(readerID,bookID) VALUES (@readerID,@bookID)
	set @ts=ltrim(str(@readerID))+''+''+ltrim(str(@bookID))+''
  end try
  begin catch
    rollback
    set @ts=ERROR_MESSAGE()
  end catch
END
GO

--
declare @tt varchar(50)
exec p_jieshu 1,5,@tt output
print @tt
exec p_jieshu 6,1,@tt output
print @tt
exec p_jieshu 1,1,@tt output
print @tt
--
select * from book
select * from reader
select * from borrow
--
drop proc p_huanshu
go
create  proc p_huanshu  @readerid int,@bookid int ,@ts varchar(50) output
as
Begin
  set nocount on
  if not EXISTS(select * from borrow where readerid=@readerid and bookid=@bookid )
  begin
     set @ts=''
     return
  end
  if not EXISTS(select * from borrow where readerid=@readerid and bookid=@bookid and returnDate is null)
  begin
     set @ts=''
     return
  end
  
  begin try
	update borrow set returnDate=GETDATE() where readerid=@readerid and bookid=@bookid and returnDate is null
	set @ts=''
  end try
  begin catch
      rollback
      set @ts=ERROR_MESSAGE()
  end catch
End


--

declare @tt varchar(50)
exec p_huanshu 1,5,@tt output
print @tt
exec p_huanshu 1,1,@tt output
print @tt

--
select * from book
select * from reader
select * from borrow
--borrow
alter table borrow
add
fk decimal(6,2)

---
drop  function f_jsfk
go
create function f_jsfk(@jsrq datetime)
returns decimal(6,2)
as
begin
  declare @fk decimal(6,2),@ts int
  set @ts=datediff(dd,@jsrq,getdate())--
  if @ts>20  --
     set @fk=(@ts-20)*0.5 
  else
     set @fk=0
  return @fk
End

---

alter  proc p_huanshu  @readerid int,@bookid int ,@ts varchar(50) output
as
Begin
  set nocount on
  if not EXISTS(select * from borrow where readerid=@readerid and bookid=@bookid )
  begin
     set @ts=''
     return
  end
  if not EXISTS(select * from borrow where readerid=@readerid and bookid=@bookid and returnDate is null)
  begin
     set @ts=''
     return
  end
  
  begin try
	update borrow set returnDate=GETDATE(),fk=dbo.f_jsfk(borrowerDate) where readerid=@readerid and bookid=@bookid and returnDate is null
	set @ts=''
  end try
  begin catch
      rollback
      set @ts=ERROR_MESSAGE()
  end catch
End

----
--1
declare @tt varchar(50)
exec p_jieshu 2,2,@tt output
print @tt

select * from book
select * from reader
select * from borrow

--2borrow 

declare @tt varchar(50)
exec p_huanshu 2,2,@tt output
print @tt


select * from book
select * from reader
select * from borrow

drop trigger tr_jsts
go
create trigger tr_jsts
on borrow
after insert
as
begin
  declare @sl int,@sm varchar(50)
  select @sl=count(*) from borrow,inserted 
    where borrow.readerid=inserted.readerid and borrow.returnDate is null
  if @sl>0
  begin
    print ''+ltrim(str(@sl))+','
    declare c_bookname cursor  --
    for 
    select bookname from book where bookid in 
      (select bookid from borrow where readerid in (select readerid from inserted) and returnDate is null)
  
    open c_bookname  --
    fetch from c_bookname into @sm  --
    while @@fetch_status=0
    begin
      print @sm
      fetch from c_bookname into @sm  --
end
close c_bookname   --
dellocate c_bookname   --
  end
end

--- 
declare @tt varchar(50)
exec p_jieshu 1,3,@tt output
print @t

create view v_boo
as
select reader.readerid,readername,department,tele,Book.bookid,bookname,publisher,KuCunLiang,borrowerDate,returnDate,fk
from reader,Book,borrow
where reader.readerID=borrow.readerID and Book.Bookid=borrow.Bookid
--
drop proc p_cxfk
go
create proc p_cxfk
@ny char(6),
@fkbs int output,
@fkzje decimal(10,2) output
as
begin
  select @fkbs=COUNT(*),@fkzje=SUM(fk) from borrow 
  where datename(YY,returnDate)=LEFT(@ny,4) and datename(mm,returnDate)=right(@ny,2)
End

--borrow
declare @fkbs int,@fkzje decimal(10,2)
exec p_cxfk '201706',@fkbs output,@fkzje output
select @fkbs,@fkzje
select * from borrow
