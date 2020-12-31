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
    public function createTeam($v1, $v2, $v3, $v4, $v5, $v6, $v7)
    {
	
		$sql = "SELECT placeID FROM app_session_user WHERE sessionID='".$v1."'";
		$resultado = $this->conn->query($sql);
		$placeID = $resultado->fetch_assoc();
        
		if ($v2 == "Round") $TableDB = "app_order_round"; else $TableDB = "app_order";
		
		$stmt = $this->conn->prepare("INSERT INTO ".$TableDB." (sessionID, orderID, productID, productDefaultOption, productQty,  payerName, billTip, placeID) VALUES (?,?,?,?,?,?,?,?)");
        
        $stmt->bind_param("ssisiiis", $v1, $v2, $v3, $v4, $v5, $v6, $v7, $placeID['placeID']);
        
        $result = $stmt->execute();
        
        $stmt->close();
        if ($result) {
            return true;
        } else {
            return false;
        }
    }
 
}
?>