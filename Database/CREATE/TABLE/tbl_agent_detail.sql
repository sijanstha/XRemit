/*  This creates the new table in the XRemit database.
Contains the fields like Agent ID, Agent Name, Agent Name, Agent Email
Agent Login Credintals
When an Agent is logged in into system, the system generates a unique aunthentication
code which is saved in aunthentication id

Author: Sijan Shrestha
Created on: 7/7/2017  */

USE XRemit;
CREATE TABLE tbl_agent_detail
(
  sno int identity(1,1),
	agent_id int not null,
	agent_login_id varchar(30),
	agent_login_pwd varbinary(100),
	agent_name varchar(30) not null,
	agent_address varchar(40),
	agent_telephone varchar(30),
	agent_mobile varchar(30),
	agent_fax varchar(30),
	agent_email varchar (8000),
	agent_authencation_id varchar(500),
	agent_is_block char,

	primary key(agent_login_id)
)
