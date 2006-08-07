-- groups
delete from groups;
insert into groups values (null, 'admin', 'administrators');
insert into groups values (null, 'users', 'common users');
insert into groups values (null, 'guest', 'guest group');

-- members
delete from members;
insert into members values (null, 'root', 'administrator', 'root@localhost', 'X', null, 1, current_timestamp, current_timestamp);
insert into members values (null, 'guest', 'guest user', null, 'X', null, 3, current_timestamp, current_timestamp);
insert into members values (null, 'foo', 'user foo', 'foo@mail.com', 'W', '1980-02-03', 2, current_timestamp, current_timestamp);
insert into members values (null, 'bar', 'user bar', 'bar@mail.net', 'W', '1981-04-05', 2, current_timestamp, current_timestamp);
insert into members values (null, 'baz', 'user baz', 'baz@mail.org', 'M', '1982-06-07', 2, current_timestamp, current_timestamp);
insert into members values (null, '<b>"X&Y"</b>', '<i>"escape test&"</i>', '"<&>"@xxx.com', 'W', '1990-01-01', 2, current_timestamp, current_timestamp);
insert into members values (null, 'aaa', 'user aaa', 'aaa@aaa.com', 'W', '1990-01-01', 2, current_timestamp, current_timestamp);
insert into members values (null, 'bbb', 'user bbb', 'bbb@bbb.com', 'W', '1990-01-01', 2, current_timestamp, current_timestamp);
insert into members values (null, 'ccc', 'user ccc', 'ccc@ccc.com', 'W', '1990-01-01', 2, current_timestamp, current_timestamp);
insert into members values (null, 'ddd', 'user ddd', 'ddd@ddd.com', 'W', '1990-01-01', 2, current_timestamp, current_timestamp);
insert into members values (null, 'eee', 'user eee', 'eee@eee.com', 'W', '1990-01-01', 2, current_timestamp, current_timestamp);
insert into members values (null, 'fff', 'user fff', 'fff@fff.com', 'W', '1990-01-01', 2, current_timestamp, current_timestamp);
insert into members values (null, 'ggg', 'user ggg', 'ggg@ggg.com', 'W', '1990-01-01', 2, current_timestamp, current_timestamp);
