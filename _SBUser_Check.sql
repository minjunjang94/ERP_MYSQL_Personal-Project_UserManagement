drop PROCEDURE _SBUser_Check;

DELIMITER $$
CREATE PROCEDURE _SBUser_Check
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
        ,OUT RETURN_OUT INT							-- IsCheck 결과 내보내기
    )
Error_Out:BEGIN -- Error_Out : 오류가 발생했을 경우 프로시져 종료

	-- 오류 관리 변수---------------------------------------
	DECLARE CompanySeq 			INT;
	DECLARE IsCheck 			INT;
    DECLARE Result  			VARCHAR(500);
	-- -------------------------------------------------
    
    -- 변수선언 --
    DECLARE Var_UserSeq		 	INT;    
    DECLARE Var_EmpSeq		 	INT;   
    DECLARE Var_CustSeq			INT;
    DECLARE Var_DeptSeq			INT;

	-- 변수설정 --
	SET Var_UserSeq = (SELECT A.UserSeq  FROM _TCBaseUser AS A WHERE A.CompanySeq = InData_CompanySeq AND A.UserId   LIKE InData_UserId  );
	SET Var_EmpSeq  = (SELECT A.EmpSeq   FROM _TSBaseEmp  AS A WHERE A.CompanySeq = InData_CompanySeq AND A.EmpName  LIKE InData_EmpName );	
    SET Var_CustSeq = (SELECT A.CustSeq  FROM _TSBaseCust AS A WHERE A.CompanySeq = InData_CompanySeq AND A.CustName LIKE InData_CustName); 
    SET Var_DeptSeq = (SELECT A.DeptSeq  FROM _TSBaseDept AS A WHERE A.CompanySeq = InData_CompanySeq AND A.DeptName LIKE InData_DeptName);   

  
	-- 오류 관리 테이블---------------------------------------
	CREATE TEMPORARY TABLE IsCheck_TEMP
    (CompanySeq INT, IsCheck INT, Result VARCHAR(500));
	INSERT INTO IsCheck_TEMP VALUES(InData_CompanySeq, 1111, '');    
	-- -------------------------------------------------	

    -- OperateFlag의 값이 'S', 'U' 외의 값이 들어갈 경우 에러발생------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
				FROM _TCBaseUser	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON InData_OperateFlag <> 'S'
                RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_2  ON InData_OperateFlag <> 'U'
                -- RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_3  ON InData_OperateFlag <> 'D' //사용자는 한번 등록하면 삭제 불가 => 정지계정으로 관리
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '[ (S) : 저장 , (U) : 업데이트 ] 외의 명령을 입력할 수 없습니다.';
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  



 	-- InData_CompanySeq, InData_UserId, InData_UserName, InData_LoginPwd, InData_PwdMailAdder 를 필수로 입력하지 않을 경우 에러발생 ------------------------------------------------
    IF ((SELECT IFNULL(A.ERR	, 1111)       AS UserSeq 
				FROM (SELECT 9999 AS ERR)	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON (
																	   (InData_CompanySeq		= 0 ) 
																	OR (InData_UserId       	= '')
                                                                    OR (InData_UserName 	   	= '')
																    OR (InData_LoginPwd 	   	= '')
																    OR (InData_PwdMailAdder	   	= '')
																 )   
															  AND (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U')
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE    
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '법인내부코드, 사용자ID, 사용자명, 패스워드, 이메일 은 필수값 입니다.'
	   WHERE (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);      
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF; -- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;   



    -- InData_CompanySeq의 값이 _TSBaseCompany.CompanySeq의 데이터에 존재하는 값이 없을 경우 에러발생 ------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.CompanySeq, 1111)  	AS CompanySeq 
				FROM _TSBaseCompany 		  	AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON  (InData_CompanySeq  <>    	A.CompanySeq ) 
															  AND (InData_OperateFlag LIKE      'S'			 )
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '등록된 법인 정보가 아닙니다. 법인등록을 해주세요.'
	   WHERE (InData_OperateFlag LIKE 'S');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  
    
    

    -- 업데이트 시 데이터가 없을 경우 에러발생 ------------------------------------------------------------------------------------------------  
    IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
				FROM _TCBaseUser	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq     =    InData_CompanySeq
															 AND A.UserId   	  =    InData_UserId
															 AND (InData_OperateFlag LIKE 'U') /*OR InData_OperateFlag LIKE 'D')*/ 
		 limit 1
         ) = (SELECT Var_UserSeq))  -- 데이터가 존재하다면 수정하려는 Seq가 같은지 여부 확인
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;

	ELSEIF InData_OperateFlag = 'S' -- Save일 경우 해당 체크가 영향 안받도록 추가
	THEN
		-- TRUE
	   SET CompanySeq = InData_CompanySeq;	

    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '업데이트할 [ 사용자ID ] 의 일치하는 데이터가 존재하지 않습니다.'
	   WHERE (InData_OperateFlag LIKE 'U'); /*OR InData_OperateFlag LIKE 'D');*/
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;       



	-- Save, Update 할 때, 사원 한 명당 2개 이상의 계정이 만들어질 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT A.EmpSeq FROM _TCBaseUser AS A WHERE A.CompanySeq = InData_CompanySeq AND A.UserId = InData_UserId) = (SELECT Var_EmpSeq)) -- 기존 사원이름이 업데이트되면 정상처리
    THEN    
 	   SET CompanySeq = InData_CompanySeq;   
    ELSE 
		IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
					FROM _TCBaseUser	 		  AS A 
					RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
																 AND A.EmpSeq    	    =    Var_EmpSeq
																 AND (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U') 
			limit 1
		     ) = (SELECT 1111)) 
		THEN
		   -- TRUE
		   SET CompanySeq = InData_CompanySeq;
		    
		ELSE
		   -- FALES
		   UPDATE IsCheck_TEMP AS A
		   SET  A.IsCheck = 9999
			   ,A.Result  = '사원 한 명당 2개 이상의 계정을 만들 수 없습니다.'
		   WHERE (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U') ;
		   -- 체크종료 구문--------------------------------------------------------------------------
		   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
		   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
		   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
		   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
		   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
		   LEAVE Error_Out; -- 프로시져 종료
		   -- ------------------------------------------------------------------------------------
		END IF;
    END IF;
 


	-- Save 할 경우 InData_UserId데이터가 _TCBaseUser.UserId 에서 중복될 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.UserSeq	, 1111)   AS UserSeq 
				FROM _TCBaseUser	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.UserId    	    =    InData_UserId
															 AND (InData_OperateFlag LIKE 'S') 
		limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '동일한 ID가 존재합니다. 다른 ID를 입력해주세요.'
	   WHERE (InData_OperateFlag LIKE 'S') ;
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;


        
 	-- InData_PwdMailAdder의 형식이 이메일 형식이 아닐 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT InData_PwdMailAdder
          WHERE InData_PwdMailAdder LIKE '%@%.%' 		
            AND (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U')
          limit 1
         ) = (SELECT InData_PwdMailAdder)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '이메일 형식이 잘못되었습니다.'
	   WHERE (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;     
    


	-- Save, Update 할 경우 InData_EmpSeq이 _TSBaseEmp.EmpSeq에 데이터가 없을 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.EmpSeq	, 1111)   	  AS EmpSeq 
				FROM _TSBaseEmp	 		  	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =   InData_CompanySeq
															 AND A.EmpSeq    	    =   Var_EmpSeq
															 AND (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U') 
		limit 1
         ) <> (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '존재하지 않는 사원명을 입력했습니다.'
	   WHERE (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U') ;
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;
    
    

	-- Save, Update 할 경우 InData_DeptSeq이 _TSBaseDept.DeptSeq에 데이터가 없을 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.DeptSeq	, 1111)   AS DeptSeq 
				FROM _TSBaseDept 		  	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =   InData_CompanySeq
															 AND A.DeptSeq    	    =   Var_DeptSeq
															 AND (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U') 
		limit 1
         ) <> (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '존재하지 않는 부서명을 입력했습니다.'
	   WHERE (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U') ;
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;
    

    
	-- Save, Update 할 경우 InData_CustSeq이 _TSBaseCust.CustSeq에 데이터가 없을 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.CustSeq	, 1111)   AS CustSeq 
				FROM _TSBaseCust 		  	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =   InData_CompanySeq
															 AND A.CustSeq    	    =   Var_CustSeq
															 AND (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U') 
		limit 1
         ) <> (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '존재하지 않는 거래처명을 입력했습니다.'
	   WHERE (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U') ;
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;
    


	DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
END $$
DELIMITER ;