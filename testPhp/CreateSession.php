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

print_r($decoded);

//including the db operation file
require_once 'DbOperation.php';
$db = new DbOperation();
	
//Process the JSON.
//creating response array
$response = array();

// Read request parameters
$var1 = $decoded["sessionID"];
$var2 = $decoded["placeID"];
$var3 = $decoded["userPassword"];
$var4 = $decoded["userEmail"];
$var5 = $decoded["tableID"];

// Store values in an array
$returnValue = array("sessionID"=>$var1, "placeID"=>$var2, "userPassword"=>$var3, "userEmail"=>$var4,"tableID"=>$var5);

//inserting values 
if($db->createTeam($var1,$var2,$var3,$var4,$var5)){
	$response['error']=false;
	$response['message']='Team added successfully';
}else{

	$response['error']=true;
	$response['message']='Could not add team';
}
// Send back request in JSON format
echo json_encode($returnValue); 

?>