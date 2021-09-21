//creataed by DIVYAM SAVSAVIYA 19DCS119
pragma solidity 0.4.25;

contract MMS {
    
//----------------data----------------
    address private faculty_address;
    
    //key=exam_code and value=bool
    mapping(string => bool) private isExamExist;
    //key=exam_code and value=Exam
    mapping(string => Exam) private exams;
    
    //key=studenID and value=bool
    mapping(string => bool) private isStudentExist;
    //key=studenID and value=Student
    mapping(string => Student) private students;
    
    //key=studenID key=exam_code value=bool
    mapping(string => mapping(string => bool)) private isMarksAssign;
    //key=studenID key=exam_code value=uint256
    mapping(string => mapping(string => uint256)) private studentsMarks;
    //key=_studentID key=exam_code value=bool
    mapping(string => mapping(string => bool)) private studentsExamResult;

    
//----------------models----------------
    struct Exam {
        string exam_code;
        uint256 total_marks;
        uint256 require_marks;
    }
    
    struct Student {
        string studenID;
    }
    
//----------------constructor----------------
    constructor() public {
        faculty_address = msg.sender;
    }
    
    
//----------------modifiers----------------
    
    //operation must done by faculty
    modifier only_faculty {
        require(faculty_address == msg.sender , "Only faculty can use this");
        _;
    }
    //exam must exist
    modifier exam_exist(string _exam_code) {
        require(isExamExist[_exam_code] , "Exam not exist!!");
        _;
    }
    //exam must not exist
    modifier exam_not_exist(string _exam_code) {
        require(!isExamExist[_exam_code] , "Exam already exist!!");
        _;
    }
    //student must exist
    modifier student_exist(string _studentID) {
        require(isStudentExist[_studentID], "Student not exist!!");
        _;
    }
    //student must not exist
    modifier student_not_exist(string _studentID) {
        require(!isStudentExist[_studentID], "Student already exist!!");
        _;
    }
    //marks must be match the constraints 
    modifier validate_marks(uint256 _total_marks,uint256 _require_marks) {
        require(_require_marks >= 0 && _require_marks <=_total_marks ,"Invalid marks");
        _;
    }
    //marks must not assigned
    modifier marks_not_assigned(string _studentID,string _exam_code) {
        require(!isMarksAssign[_studentID][_exam_code],"marks already assign");
        _;
    }
    modifier validate_assigned_marks(string _exam_code,uint256 _assigned_marks) {
        require(_assigned_marks<=exams[_exam_code].total_marks,"Invalid marks");
        _;
    }
    
//----------------functions----------------
    function add_exam(
        string _exam_code,
        uint256 _total_marks,
        uint256 _require_marks)
        public
        only_faculty
        exam_not_exist(_exam_code)
        validate_marks(_total_marks,_require_marks)
        {
            isExamExist[_exam_code]=true;
            exams[_exam_code]=Exam(_exam_code,_total_marks,_require_marks);
        }
        
    function add_students(
        string _studentID)
        public
        only_faculty
        student_not_exist(_studentID)
        {
            isStudentExist[_studentID]=true;
            students[_studentID]=Student(_studentID);
        }
        
    function assign_marks(
        string _studentID,
        string _exam_code,
        uint256 _assigned_marks)
        public
        only_faculty
        student_exist(_studentID)
        exam_exist(_exam_code)
        marks_not_assigned(_studentID,_exam_code)
        validate_assigned_marks(_exam_code,_assigned_marks)
        {
            isMarksAssign[_studentID][_exam_code]=true;
            studentsMarks[_studentID][_exam_code]=_assigned_marks;
            updateStudentExamResult(_studentID,_exam_code,_assigned_marks);
        }
    
    function updateStudentExamResult(
        string _studentID,
        string _exam_code,
        uint256 _assigned_marks)
        private
        {
            if(_assigned_marks < exams[_exam_code].require_marks) {
                studentsExamResult[_studentID][_exam_code]=false;
            } else {
                studentsExamResult[_studentID][_exam_code]=true;
            }
        }
        
    event showDetails(
        string _studentID,
        string _exam_code,
        bool _isMarksAssign,
        uint256 _studentsMarks,
        bool studentsExamResult);
    
    function getDetails(
        string _studentID,
        string _exam_code)
        public
        only_faculty
        student_exist(_studentID)
        exam_exist(_exam_code)
        {
            emit showDetails(_studentID,
                    _exam_code,
                    isMarksAssign[_studentID][_exam_code],
                    studentsMarks[_studentID][_exam_code],
                    studentsExamResult[_studentID][_exam_code]);
        }
        
}