-- -- Contains the information about failed login attempt of several users in this
-- -- system.
-- -- Fetches the information that is crucial for blocking any irregular login attempt
-- -- in system. If the failed login attempt reaches upto limit 3 then the user is
-- -- suspended for limited amount of time.
-- Author: Sijan Shrestha
-- Created on: 7/7/2017

USE XRemit;
CREATE TABLE tbl_system_access_log
(
  sno int identity(1,1),
  login_id varchar(30),
  user_type varchar(30),
  access_attempt int,
  authenication_id varchar(200),
  time_stamp varchar(30),
  ip varchar(30),
  mac_ip varchar(30),
  primary key(sno)
)
