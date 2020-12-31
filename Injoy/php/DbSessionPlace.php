<?php
header("Access-Control-Allow-Origin: *");
$con = mysqli_connect("localhost","zmr_InjoyAppIosUser", "Juan123", "zmr_InjoyAppIos") or die ("could not connect database");
if (mysqli_connect_errno()){ echo "Failed to connect to MySQL: " . mysqli_connect_error(); }

if (!isset($_GET['ID'])) $_GET['ID'] = 1;
if (!isset($_GET['OP'])) $_GET['OP'] = 1;
// This SQL statement selects ALL from the table 'Locations'
if     ($_GET['OP'] == 1){
	// PLACE ID /** SELECCION SESSION ID INFO **/
	$sql = "SELECT *
			FROM app_place
			WHERE placeID = '".$_GET['ID']."'
			AND 1=1";
}elseif($_GET['OP'] == 2){
	// PLACE ID /** SELECCION PLACE NAME **/
	$sql = "SELECT placeName
			FROM app_place
			WHERE placeID = '".$_GET['ID']."'
			AND 1=1";
}elseif($_GET['OP'] == 3){
	// SESSION ID /** SELECCION SESSION ID STATUS O NO**/
 	$sql = "SELECT U.sessionStatus
			FROM app_session_user U
			WHERE U.sessionID = '".$_GET['ID']."'";
}

// Check if there are results
if ($result = mysqli_query($con, $sql)){
	// If so, then create a results array and a temporary one to hold the data
	$resultArray = array();
	// Loop through each row in the result set
	$row = $result->fetch_assoc();
	array_push($resultArray , $row);
	// Finally, encode the array to JSON and output the results
	echo  json_encode( $resultArray, JSON_NUMERIC_CHECK );
}
// Close connections
mysqli_close($con);
?>
