drop PROCEDURE _SBUser;

DELIMITER $$
CREATE PROCEDURE _SBUser
	(
		 InData_OperateFlag		CHAR(2)			-- 작업표시
		,InData_CompanySeq		INT				-- 법인내부코드
		,InData_UserId			VARCHAR(100)	-- 사용자ID
		,InData_UserName 		VARCHAR(30)		-- 사용자명
		,InData_EmpName			VARCHAR(40)		-- 사원명
		,InData_LoginPwd        VARCHAR(50)		-- 패스워드
		,InData_CustName		VARCHAR(100)	-- 거래처명
		,InData_DeptName		VARCHAR(100)	-- 부서명
		,InData_PwdMailAdder	VARCHAR(50)		-- 비밀번호 전송 이메일
		,InData_Remark			VARCHAR(100)	-- 비고
		,Login_UserSeq			INT				-- 현재 로그인 중인 유저
    )
BEGIN
    
    DECLARE State INT;
    
    -- ---------------------------------------------------------------------------------------------------
    -- Check --
	call _SBUser_Check
		(
			 InData_OperateFlag		
			,InData_CompanySeq		
			,InData_UserId			
			,InData_UserName 		
			,InData_EmpName			
			,InData_LoginPwd        
			,InData_CustName		
			,InData_DeptName		
			,InData_PwdMailAdder	
			,InData_Remark			
			,Login_UserSeq			
			,@Error_Check
		);
    

	IF( @Error_Check = (SELECT 9999) ) THEN
		
        SET State = 9999; -- Error 발생
        
	ELSE

	    SET State = 1111; -- 정상작동
        
		-- ---------------------------------------------------------------------------------------------------
		-- Save --
		IF( InData_OperateFlag = 'S' AND STATE = 1111 ) THEN
			call _SBUser_Save
				(
					 InData_OperateFlag		
					,InData_CompanySeq		
					,InData_UserId			
					,InData_UserName 		
					,InData_EmpName			
					,InData_LoginPwd        
					,InData_CustName		
					,InData_DeptName		
					,InData_PwdMailAdder	
					,InData_Remark			
					,Login_UserSeq	
				);
		END IF;	
    
		-- ---------------------------------------------------------------------------------------------------
		-- Update --
		IF( InData_OperateFlag = 'U' AND STATE = 1111 ) THEN
			call _SBUser_Update
				(
					 InData_OperateFlag		
					,InData_CompanySeq		
					,InData_UserId			
					,InData_UserName 		
					,InData_EmpName			
					,InData_LoginPwd        
					,InData_CustName		
					,InData_DeptName		
					,InData_PwdMailAdder	
					,InData_Remark			
					,Login_UserSeq	
				);		
		END IF;	    

	END IF;
END $$
DELIMITER ;