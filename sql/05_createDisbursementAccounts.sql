create table disbursementAccounts (
       ID int unsigned auto_increment primary key,
       OccurDate date
       Disbursement bigint,
       Description text,
       ItemKindId int unsigned,
       AccountFrom int unsigned,
       AccountTo int unsigned,
       InputDate datetime,
       LastModified datetime
);
alter table disbursementAccounts add foreign key(ItemKindId) references itemKinds(ID) on update cascade on delete restrict;
alter table disbursementAccounts add foreign key(AccountFrom) references accounts(ID) on update cascade on delete restrict;
alter table disbursementAccounts add foreign key(AccountTo) references accounts(ID) on update cascade on delete restrict;
