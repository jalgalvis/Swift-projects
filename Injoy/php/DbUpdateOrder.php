<?php
 
class DbOperation
{
    private $conn;
 
    //Constructor
    function __construct()
    {
        require_once dirname(__FILE__) . '/Config.php';
        require_once dirname(__FILE__) . '/DbConnect.php';
        // opening db connection
        $db = new DbConnect();
        $this->conn = $db->connect();
    }
 
    //Function to create a new user
    public function createTeam($v1, $v2, $v3, $v4)
    {
	
		$sql = "UPDATE app_order SET payerName='".$v3."', billTip='".$v4."' WHERE sessionID='".$v1."'";
		$resultado = $this->conn->query($sql);
		$placeID = $resultado->fetch_assoc();
        
        $stmt->close();
        if ($result) {
            return true;
        } else {
            return false;
        }
    }
 
}
?>