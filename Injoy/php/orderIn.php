<?php
header('Content-type: application/json');

//Make sure that it is a POST request.
if(strcasecmp($_SERVER['REQUEST_METHOD'], 'POST') != 0){
    throw new Exception('Request method must be POST!');
}
print_r($_SERVER["CONTENT_TYPE"]);
//Make sure that the content type of the POST request has been set to application/json
$contentType = isset($_SERVER["CONTENT_TYPE"]) ? trim($_SERVER["CONTENT_TYPE"]) : '';
/*
if(strcasecmp($contentType, 'application/json') != 0){
    throw new Exception('Content type must be: application/json');
}/**/

//Receive the RAW post data.
$content = trim(file_get_contents("php://input"));

//Attempt to decode the incoming RAW post data from JSON.
$decoded = json_decode($content, true);

//If json_decode failed, the JSON is invalid.
if(!is_array($decoded)){
    throw new Exception('Received content contained invalid JSON!');
}

//including the db operation file
require_once 'DbInsertOrder.php';
$db = new DbOperation();
	
//Process the JSON.
//creating response array
$response = array();

foreach ($decoded as $var) {

	// Read request parameters
	$v1 = $var["sessionID"];
	$v2 = $var["orderID"];
	$v3 = $var["productID"];
	$v4 = $var["productDefaultOption"];
	$v5 = $var["productQty"];
	$v6 = $var["payerName"];
	$v7 = $var["billTip"];
	
	// Store values in an array
	$returnValue = array("sessionID"=>$v1, "orderID"=>$v2, "productID"=>$v3, "productDefaultOption"=>$v4,"productQty"=>$v5, "payerName"=>$v6, "billTip"=>$v7);
	 
	//inserting values 
	if($db->createTeam($v1,$v2,$v3,$v4,$v5, $v6, $v7)){
		$response['error']=false;
		$response['message']='Team added successfully';
	}else{
		$response['error']=true;
		$response['message']='Could not add team';
	}    
	// Send back request in JSON format
	echo json_encode($returnValue); 
}
?>