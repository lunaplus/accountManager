create table itemKinds (
       ID int unsigned auto_increment primary key,
       Name varchar(20),
       SortOrder int unsigned,
       Expired bool,
       UserId varchar(8),
       LastModified datetime,
       foreign key (UserId)
       references cgiUsers(UID)
       on update cascade
       on delete restrict
);
