drop PROCEDURE _SBUser_Update;

DELIMITER $$
CREATE PROCEDURE _SBUser_Update
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
    DECLARE Var_UserSeq				INT;    
    DECLARE Var_EmpSeq				INT;
    DECLARE Var_CustSeq				INT;
    DECLARE Var_DeptSeq				INT;
    DECLARE Var_GetDateNow			VARCHAR(100);
    
	SET Var_UserSeq     = (SELECT A.UserSeq FROM _TCBaseUser AS A WHERE A.CompanySeq = InData_CompanySeq AND A.UserId   LIKE InData_UserId  );
    SET Var_EmpSeq      = (SELECT A.EmpSeq  FROM _TSBaseEmp  AS A WHERE A.CompanySeq = InData_CompanySeq AND A.EmpName  LIKE InData_EmpName ); 
    SET Var_CustSeq     = (SELECT A.CustSeq FROM _TSBaseCust AS A WHERE A.CompanySeq = InData_CompanySeq AND A.CustName LIKE InData_CustName); 
    SET Var_DeptSeq     = (SELECT A.DeptSeq FROM _TSBaseDept AS A WHERE A.CompanySeq = InData_CompanySeq AND A.DeptName LIKE InData_DeptName);          
	SET Var_GetDateNow  = (SELECT DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s") AS GetDate); -- 작업일시는 Update 되는 시점의 일시를 Insert

    -- ---------------------------------------------------------------------------------------------------
    -- Update --
	IF( InData_OperateFlag = 'U' ) THEN     
			UPDATE _TCBaseUser				AS A
			   SET	A.EmpSeq				= Var_EmpSeq
				   ,A.CustSeq				= Var_CustSeq
				   ,A.DeptSeq				= Var_DeptSeq
				   ,A.PwdMailAdder			= InData_PwdMailAdder
				   ,A.Remark				= InData_Remark
				   ,A.LastUserSeq			= Login_UserSeq
				   ,A.LastDateTime			= Var_GetDateNow
			WHERE A.CompanySeq				= InData_CompanySeq 
			  AND A.UserSeq					= Var_UserSeq;  
                     
              SELECT '저장되었습니다.' AS Result; 
                     
	ELSE
			  SELECT '저장이 완료되지 않았습니다.' AS Result;
	END IF;	


END $$
DELIMITER ;