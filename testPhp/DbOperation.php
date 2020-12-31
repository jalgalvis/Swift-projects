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
    public function createTeam($var1, $var2, $var3, $var4, $var5)
    {
        $stmt = $this->conn->prepare("INSERT INTO app_session_user (sessionID, placeID, userPassword, userEmail, tableID) VALUES (?,?,?,?,?)");
        
        $stmt->bind_param("sissi", $var1, $var2, $var3, $var4, $var5);
        
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