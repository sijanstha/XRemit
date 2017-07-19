Use XRemit;
CREATE TABLE tbl_branch_detail (
    sno int identity(1,1) not null,
    branch_login_id varchar(255),
    branch_login_password varbinary(100),
	branch_name varchar(255),
    branch_phone varchar(255),
    branch_email varchar(255), 
	branch_address varchar(255),
	branch_fax varchar(255),
	branch_authentication_id varchar(100),
	branch_is_block char,
	branch_img text,

	PRIMARY KEY(sno)
);

