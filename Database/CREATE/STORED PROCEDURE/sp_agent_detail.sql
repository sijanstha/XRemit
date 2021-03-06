USE [XRemit]
GO
/****** Object:  StoredProcedure [dbo].[sp_agent_detail]    Script Date: 7/12/2017 5:57:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- This is the stored procedure for the table tbl_agent_detail
-- Perfroms all basic CRUD operations.
--   Flag Status
--   -----------------
--   's' -> selecting the table fields
--   'i' -> inserting into table fields
--   'u' -> updating the table fields
--   'd' -> deleting table fields
--   'a' -> for authenication to get access into system
--
--   Error code
--   ------------
--   - ranges from 1000 to 1999
--   '0' -> SUCCESS
--  '1000' ->

CREATE PROCEDURE [dbo].[sp_agent_detail]
(
  @flag char = NULL,
  @agent_id int =NULL,
  @agent_login_id varchar(200) = NULL,
  @agent_login_pwd varchar(300) = NULL,
  @agent_name varchar(40) = NULL,
  @agent_address varchar(50) = NULL,
  @agent_telephone varchar(30) = NULL,
  @agent_mobile varchar(30) = NULL,
  @agent_fax varchar(30) = NULL,
  @agent_email varchar (8000) = NULL,
  @agent_authencation_id varchar(500) = NULL,
  @agent_is_block char = NULL,
  @ip varchar(30) = NULL,
  @mac varchar(55) = NULL,
  @agent_img varchar(400) = NULL
)
AS
--SET NOCOUNT ON right at the beginning to suppress the "n rows affected" counts so JDBC doesn't get confused as to what it should put into the ResultSet:
SET NOCOUNT ON
BEGIN
    IF @flag is NULL OR @flag = ''
    BEGIN
      SELECT '1000' AS CODE, 'FLAG CANNOT BE EMPTY' AS MSG
    END

    ELSE
    BEGIN
      IF @flag = 'S'
      BEGIN
            SELECT '0' AS CODE, * FROM tbl_agent_detail
      END

      ELSE IF @flag = 'I'
      BEGIN
			IF @agent_img IS NULL OR @agent_img =''
				BEGIN
					SET @agent_img = 'profile.png'
				END
            IF @agent_login_id IS NULL OR @agent_login_pwd IS NULL OR @agent_name IS NULL OR @agent_address IS NULL OR @agent_telephone IS NULL OR @agent_mobile IS NULL OR @agent_fax IS NULL OR @agent_email IS NULL
            BEGIN
              SELECT '1001' AS CODE, 'REQUIRED FIELDS CANNOT BE NULL' AS MSG
              RETURN
            END
            IF @agent_login_id ='' OR @agent_login_pwd ='' OR @agent_name ='' OR @agent_address ='' OR @agent_telephone ='' OR @agent_mobile ='' OR @agent_fax ='' OR @agent_email =''
            BEGIN
            SELECT '1002' AS CODE, 'REQUIRED FIELDS CANNOT BE EMPTY' AS MSG
            RETURN
            END

            INSERT INTO tbl_agent_detail (agent_id, agent_login_id, agent_login_pwd, agent_name, agent_address, agent_telephone, agent_mobile, agent_fax, agent_email, agent_is_block)
            VALUES (@agent_id, @agent_login_id, PWDENCRYPT(@agent_login_pwd), @agent_name, @agent_address, @agent_telephone, @agent_mobile, @agent_fax, @agent_email, 'N')

            SELECT '0' AS CODE, 'INSERTED SUCCESSFULLY' AS MSG
      END

      ELSE IF @flag = 'A'
      BEGIN
          IF @agent_login_id IS NULL OR @agent_login_pwd IS NULL OR @agent_login_id ='' OR @agent_login_pwd =''
          BEGIN
              SELECT '1003' AS CODE, 'LOGIN Credintals CANNOT BE EMPTY/NULL' AS MSG
              RETURN
          END
          --HERE COMES THE BEST PART
          --CHECKING IF THE LOGIN Credintals IS GOOD
		  
          declare @pwdCompare as int
          SELECT @pwdCompare = PWDCOMPARE(@agent_login_pwd,agent_login_pwd) FROM tbl_agent_detail WHERE (agent_login_id = @agent_login_id AND agent_is_block = 'N')
          --GENERATING RANDOM SESSION ID
          declare @authentication_random_id varchar(100)
          SELECT @authentication_random_id = CAST(RAND()*10.00 as VARCHAR)
          --IF ALL OKAY THEN
          IF @pwdCompare=1
          BEGIN
              UPDATE tbl_agent_detail SET agent_authencation_id = @authentication_random_id where agent_login_id = @agent_login_id
			  DELETE FROM tbl_system_access_log WHERE login_id=@agent_login_id
              SELECT '0' AS CODE, 'SESSION STARTED' AS MSG
          END

          --IF NOT THEN
		  ELSE
		  BEGIN
				DECLARE @login_count as int
				SELECT @login_count = isnull(access_attempt,0) FROM tbl_system_access_log where (login_id=@agent_login_id AND user_type='agent')
				--first error in password
				IF @login_count IS NULL
				BEGIN
					INSERT INTO tbl_system_access_log (login_id, user_type, access_attempt, authenication_id, time_stamp, ip, mac_ip)
					VALUES(@agent_login_id, 'agent', 1, @authentication_random_id, CURRENT_TIMESTAMP, @ip, @mac)
					SELECT '1004' AS CODE, 'Invalid Login Credintals' AS MSG
					RETURN
				END
				IF @login_count<3
				BEGIN
					UPDATE tbl_system_access_log SET access_attempt=@login_count+1,ip=@ip,mac_ip=@mac WHERE (login_id=@agent_login_id AND user_type='agent')
					SELECT '1004' AS CODE, 'Invalid Login Credintals' AS MSG
					RETURN
				END
				UPDATE tbl_agent_detail SET agent_is_block='Y' WHERE agent_login_id=@agent_login_id
					SELECT '1005' AS CODE, 'Your Id Has been blocked temporarily' AS MSG
		  END
         
      END

    END
END
