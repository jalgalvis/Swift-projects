<?php
// header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
$con = mysqli_connect("localhost","zmr_InjoyAppIosUser", "Juan123", "zmr_InjoyAppIos") or die ("could not connect database");
if (mysqli_connect_errno()){ echo "Failed to connect to MySQL: " . mysqli_connect_error(); }

if (!isset($_GET['PID'])) $_GET['PID'] = 1;

$sql = "SELECT productID, productName, productPhotoURL, placeID, productDescription, productKind, productRoundable, productVAT, popular, offer
		FROM app_product
		WHERE available = 1
		AND placeID =".$_GET['PID']."
		ORDER BY productKind";

		// echo "<br>".$sql;
// Check if there are results

if ($result = mysqli_query($con, $sql)){
	// If so, then create a results array and a temporary one to hold the data
	$resultArray = array();
	$row = array();

	// Loop through each row in the result set
	while($row = $result->fetch_assoc()){

		$sql = "SELECT optionS, price
				FROM app_product_option
				WHERE productID = ".$row['productID'];

		// echo "<br>".$sql;
		if ($result2 = mysqli_query($con, $sql)) {
			$new_array = array();
			$opc = array();


			while($opc = $result2->fetch_assoc()){
					$new_array['productOptionPrice'][$opc['optionS']]=$opc['price'];
					$row = array_merge($row, $new_array);
		}
	}
		array_push($resultArray, $row);
	}
	// Finally, encode the array to JSON and output the results
	echo json_encode( $resultArray, JSON_NUMERIC_CHECK | JSON_PRETTY_PRINT );
}
// Close connections
mysqli_close($con);
?>
