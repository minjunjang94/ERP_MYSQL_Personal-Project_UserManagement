drop PROCEDURE _SBUser_Save;

DELIMITER $$
CREATE PROCEDURE _SBUser_Save
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

	-- 변수선언
    DECLARE Var_EmpSeq				INT;
    DECLARE Var_CustSeq				INT;
    DECLARE Var_DeptSeq				INT;
    DECLARE Var_LoginStatus			INT;
    DECLARE Var_GetDateNow			VARCHAR(100);
    DECLARE Var_PwdChgDate			VARCHAR(8);
    
    SET Var_EmpSeq      = (SELECT A.EmpSeq  FROM _TSBaseEmp  AS A WHERE A.CompanySeq = InData_CompanySeq AND A.EmpName  = InData_EmpName ); 
    SET Var_CustSeq     = (SELECT A.CustSeq FROM _TSBaseCust AS A WHERE A.CompanySeq = InData_CompanySeq AND A.CustName = InData_CustName); 
    SET Var_DeptSeq     = (SELECT A.DeptSeq FROM _TSBaseDept AS A WHERE A.CompanySeq = InData_CompanySeq AND A.DeptName = InData_DeptName); 
    SET Var_LoginStatus = 1005001; -- 1005001 : 정상진입 // _TSBaseMajor(1005) : 로그인상태확인
    SET Var_PwdChgDate  = (SELECT DATE_FORMAT(NOW(), "%Y%m%d") AS GetDate);  -- 비밀번호변경일 Save되는 시점의 일시를 Insert
	SET Var_GetDateNow  = (SELECT DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s") AS GetDate); -- 작업일시는 Save되는 시점의 일시를 Insert

    -- ---------------------------------------------------------------------------------------------------
    -- Insert --
	IF( InData_OperateFlag = 'S' ) THEN
		INSERT INTO _TCBaseUser 
		( 	 
			 CompanySeq			-- 법인내부코드
			,UserId				-- 사용자ID
			,UserName			-- 사용자명
			,EmpSeq				-- 사원내부코드
			,LoginPwd			-- 비밀번호
			,PasswordHis1		-- 비밀번호 History 1
			,PasswordHis2		-- 비밀번호 History 2
			,CustSeq			-- 거래처내부코드
			,DeptSeq			-- 부서내부코드
			,LoginStatus		-- 로그인상태
			,PwdChgDate			-- 비밀번호변경일
			,PwdMailAdder		-- 이메일
			,LoginFailCnt		-- 로그인 실패수
			,Remark				-- 비고
			,LastUserSeq		-- 작업자
			,LastDateTime		-- 작업일시
        )
		VALUES
		(
			 InData_CompanySeq		
			,InData_UserId			
			,InData_UserName		
			,Var_EmpSeq			
			,InData_LoginPwd		
			,''						-- 초기 저장 시 PasswordHis1 
			,''						-- 초기 저장 시 PasswordHis2
			,Var_CustSeq		
			,Var_DeptSeq		
			,Var_LoginStatus	
			,Var_PwdChgDate			
			,InData_PwdMailAdder	
			,0						-- 초기 저장 시 로그인 실패수
			,InData_Remark			
			,Login_UserSeq	
			,Var_GetDateNow			-- LastDateTime //작업일시
		);
        
        SELECT '저장이 완료되었습니다' AS Result;
	END IF;	

END $$
DELIMITER ;