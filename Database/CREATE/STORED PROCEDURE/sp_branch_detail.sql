CREATE PROCEDURE sp_branch_detail(
	@flag char=null, 
	
    @branch_login_id varchar(255) = null,
    @branch_login_password varchar(255) = null,
	@branch_name varchar(255) = null,
    @branch_phone varchar(255) = null,
    @branch_email varchar(255) = null, 
	@branch_address varchar(255) = null,
	@branch_fax varchar(255) = null,
	@agent_authencation_id varchar(100) = null,
	@branch_is_block char = null,
	@branch_img varchar(400) = null
)
AS
BEGIN
	IF @flag IS NULL OR @flag=''
		BEGIN
		SELECT '2000' AS CODE, 'EMPTY CASE' AS MSG
		END
	ELSE
		IF @flag='i'
			BEGIN
				IF @branch_img IS NULL OR @branch_img =''
				BEGIN
					SET @branch_img = 'profile.png'
				END
				INSERT INTO tbl_branch_detail (branch_login_id,branch_login_password,branch_name,branch_phone,branch_email,branch_address,branch_fax,branch_is_block,branch_img)
				VALUES(@branch_login_id,pwdencrypt(@branch_login_password),@branch_name , @branch_phone, @branch_email ,@branch_address ,@branch_fax,'N',@branch_img)
				SELECT '0' AS CODE, 'DATA INSERTED' AS MSG
			END

		ELSE IF @flag='a'
			BEGIN
				IF @branch_login_id IS NULL OR @branch_login_password IS NULL OR @branch_login_id ='' OR @branch_login_password =''
          BEGIN
              SELECT '2003' AS CODE, 'LOGIN Credintals CANNOT BE EMPTY/NULL' AS MSG
              RETURN
          END
          --HERE COMES THE BEST PART
          --CHECKING IF THE LOGIN Credintals IS GOOD
		  
          declare @pwdCompare as int
          SELECT @pwdCompare = PWDCOMPARE(@branch_login_password, branch_login_password) FROM tbl_branch_detail WHERE (branch_login_id = @branch_login_id AND branch_is_block = 'N')
          --GENERATING RANDOM SESSION ID
          declare @authentication_random_id varchar(100)
          SELECT @authentication_random_id = CAST(RAND()*10.00 as VARCHAR)
          --IF ALL OKAY THEN
          IF @pwdCompare=1
          BEGIN
              UPDATE tbl_branch_detail SET branch_authentication_id = @authentication_random_id where branch_login_id = @branch_login_id
			  DELETE FROM tbl_system_access_log WHERE login_id=@branch_login_id
              SELECT '0' AS CODE, 'SESSION STARTED' AS MSG
          END

          --IF NOT THEN
		  ELSE
		  BEGIN
				DECLARE @login_count as int
				SELECT @login_count = isnull(access_attempt,0) FROM tbl_system_access_log where (login_id=@branch_login_id AND user_type='branch')
				--first error in password
				IF @login_count IS NULL
				BEGIN
					INSERT INTO tbl_system_access_log (login_id, user_type, access_attempt, authenication_id, time_stamp, ip, mac_ip)
					VALUES(@branch_login_id, 'branch', 1, @authentication_random_id, CURRENT_TIMESTAMP, '', '')
					SELECT '2004' AS CODE, 'Invalid Login Credintals' AS MSG
					RETURN
				END
				IF @login_count<3
				BEGIN
					UPDATE tbl_system_access_log SET access_attempt=@login_count+1,ip='',mac_ip='' WHERE (login_id=@branch_login_id AND user_type='branch')
					SELECT '2004' AS CODE, 'Invalid Login Credintals' AS MSG
					RETURN
				END
				UPDATE tbl_branch_detail SET branch_is_block='Y' WHERE branch_login_id=@branch_login_id
					SELECT '2005' AS CODE, 'Your Id Has been blocked temporarily' AS MSG
		  END
			END
		

END

