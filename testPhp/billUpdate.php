<?php
//creating response array
$response = array();

// Read request parameters
$v1 = $_REQUEST["sessionID"];
$v2 = $_REQUEST["orderID"];
$v3 = $_REQUEST["payerName"];
$v4 = $_REQUEST["billTip"];

// Store values in an array
$returnValue = array("sessionID"=>$v1, "orderID"=>$v2, "payerName"=>$v3, "billTip"=>$v4);

 
    //including the db operation file
    require_once 'DbUpdateOrder.php';
 
    $db = new DbOperation();
 
    //inserting values 
    if($db->createTeam($v1,$v2,$v3,$v4)){
        $response['error']=false;
        $response['message']='Team added successfully';
    }else{
 
        $response['error']=true;
        $response['message']='Could not add team';
    }
    
// Send back request in JSON format
echo json_encode($returnValue); 

?>