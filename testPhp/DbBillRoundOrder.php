<?php
header("Access-Control-Allow-Origin: *"); 
$con = mysqli_connect("localhost","injoycom_root", "cotoplas2017", "injoycom_wp") or die ("could not connect database");
if (mysqli_connect_errno()){ echo "Failed to connect to MySQL: " . mysqli_connect_error(); }

if (!isset($_GET['ID'])) $_GET['ID'] = 1;
if (!isset($_GET['SID'])) $_GET['SID'] = 1;
if (!isset($_GET['OP'])) $_GET['OP'] = 1;

if     ($_GET['OP'] == 1){
	// SESSION ID /** BILL **/
	$sql = "SELECT O.*, AP.productID, AP.placeID, AP.productName, AP.productDescription, AP.productKind, AP.productRoundable, AP.productVAT 
			FROM app_order O, app_product AP 
			WHERE O.sessionID = '".$_GET['ID']."'
			AND O.productID = AP.productID";
}elseif($_GET['OP'] == 2){
	// SESSION ID /** ROUND **/
	$sql = "SELECT O.*, AP.productID, AP.placeID, AP.productName, AP.productDescription, AP.productKind, AP.productRoundable, AP.productVAT 
			FROM app_order_round O, app_product AP 
			WHERE O.sessionID = '".$_GET['ID']."'
			AND O.productID = AP.productID";
}elseif($_GET['OP'] == 3){
	// ORDER ID /** ORDER **/
	$sql = "SELECT O.*, AP.productID, AP.placeID, AP.productName, AP.productDescription, AP.productKind, AP.productRoundable, AP.productVAT 
		FROM app_order O, app_product AP 
		WHERE O.orderID = '".$_GET['ID']."'
		AND O.sessionID = '".$_GET['SID']."'
		AND O.productID = AP.productID";
}

	
// Check if there are results
if ($result = mysqli_query($con, $sql)){
	// If so, then create a results array and a temporary one to hold the data
	$resultArray = array();
	$row = array();
	$opc = array();
 
	// Loop through each row in the result set
	while($row = $result->fetch_assoc()){
		
		$sql = "SELECT optionS, price
				FROM app_product_option
				WHERE productID = ".$row['productID']." 
				AND optionS = '".$row['productDefaultOption']."'";
				
		if ($result2 = mysqli_query($con, $sql)) {
			$new_array = array();
			$opc = array();
			while($opc = $result2->fetch_assoc()){
					$new_array['productOptionPrice'][$opc['optionS']]=$opc['price'];
					$row = array_merge($row, $new_array);
			}
		}
		array_push($resultArray , $row);
	}
	// Finally, encode the array to JSON and output the results
	echo  json_encode( $resultArray, JSON_NUMERIC_CHECK );
}
// Close connections  
mysqli_close($con);
?>