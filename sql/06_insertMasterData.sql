insert into itemKinds(Name,SortOrder,Expired,UserId,LastModified)
  values('食費、日用',1,false,'admin',now());

insert into Accounts(Name,SortOrder,Expired,UserId,Remainder,LastModified)
  values('財布',0,false,'admin',0,now());
insert into Accounts(Name,SortOrder,Expired,UserId,Remainder,LastModified)
  values('支出',1,false,'admin',0,now());
insert into Accounts(Name,SortOrder,Expired,UserId,Remainder,LastModified)
  values('UFJ銀行',2,false,'admin',0,now());
