-- blocks the user if tries to access the system with invalid credintals multiple times eith sampe ip and mac address
-- flag 'dl' -> delete list
-- flah 'lf' -> if login falied
-- error range 7000 - 7999
-- Author: Sijan Shrestha
-- Created on: 7/7/2017


CREATE PROCEDURE sp_system_access_log
(
  @flag char(2) = NULL,
	@login_id varchar(30) = NULL,
	@user_type varchar(20) = NULL,
	@access_attempt int = NULL,
	@authenication_id varchar(200) = NULL,
	@time_stamp varchar(30)= NULL,
	@ip varchar(30) = NULL,
	@mac_ip varchar(30) = NULL,
  @sp_name varchar(40) = NULL   -- for keeping track from which user has the request is requested(specific stored procedure)
)
AS
BEGIN
    IF @flag IS NULL OR @flag = ''
    BEGIN
        SELECT '7000' AS CODE, 'FLAG CANNOT BE EMPTY/NULL' AS MSG
        RETURN
    END
    IF @flag='lf'
    BEGIN
        IF @login_id IS NULL OR @login_id=''
        BEGIN
            SELECT '7001' AS CODE,'EMPTY CASE' AS MSG
            RETURN
        END
        --DECLARING login_count VARIABLE FOR COUNTING FAILED access_attempt
        declare @login_count as int
        SELECT @login_count = access_attempt FROM tbl_system_access_log WHERE login_id=@login_id AND (mac_ip=@mac_ip AND ip=@ip)
        SELECT @login_count AS MSG
        --CHECKING IF login_count IS GREATER THAN 3 OR not
        IF @login_count>3
          BEGIN
          --UPDATING specific table FOR BLOCKING USER
          EXEC @sp_name @flag='s'
          RETURN
          END

    END

	if @flag='tr'
	begin
	insert into tbl_system_access_log (login_id) values(@login_id)
	end
END
