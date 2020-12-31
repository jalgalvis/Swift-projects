<?php
// header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

$con = mysqli_connect("localhost","zmr_tableViewJsonUser", "Juan123", "zmr_tableViewJsonBD") or die ("could not connect database");
if (mysqli_connect_errno()){ echo "Failed to connect to MySQL: " . mysqli_connect_error(); }

$latToNorth = $_GET['latToNorth'];
$latToSouth = $_GET['latToSouth'];
$lonToEast = $_GET['lonToEast'];
$lonToWest = $_GET['lonToWest'];

// This SQL statement selects ALL from the table 'Restaurants'
$sql = "SELECT id, name, imageURL, latitude, longitude, rating, eatInOption, takeAwayOption, deliveryOption,	chickenOption, beefOption,	porkOption, fishOption,	seaFoodOption, vegetarianOption
		FROM restaurant
		WHERE latitude BETWEEN '".$latToSouth."' AND '".$latToNorth."'
		AND longitude BETWEEN '".$lonToWest."' AND '".$lonToEast."'
		ORDER BY id";

	// echo $sql;

// Check if there are results
if ($result = mysqli_query($con, $sql)){
	// If so, then create a results array and a temporary one to hold the data
	$resultArray = array();
	$row = array();


	// Loop through each row in the result set
	while($row = $result->fetch_assoc()){

		$sql = "SELECT id, name, categoryId, restaurantId, optionId
				FROM portion
				WHERE restaurantId = ".$row['id'];


		if ($result2 = mysqli_query($con, $sql)) {
			$portionsArray = array();
			$portions = array();

			while($portions = $result2->fetch_assoc()){
					$portionsArray[] = array('id' => $portions['id'],
					'name' => $portions['name'],
					'categoryId' => $portions['categoryId'],
					'restaurantId' => $portions['restaurantId'],
					'optionId' => $portions['optionId']);
			}
		}

		$sql = "SELECT id, name, restaurantId
				FROM portionOption
				WHERE restaurantId = ".$row['id'];

				// echo $sql;
		if ($result3 = mysqli_query($con, $sql)) {
			$optionsArray = array();
			$options = array();

			while($options = $result3->fetch_assoc()){
					$optionsArray[] = array('id' => $options['id'],
					'name' => $options['name'],
					'restaurantId' => $options['restaurantId']);
			}
		}



			$resultArray[] = array('id' => $row['id'],
			'name' => $row['name'],
			'imageURL' => $row['imageURL'],
			'latitude' => $row['latitude'],
			'longitude' => $row['longitude'],
			'rating' => $row['rating'],
			'portions' => $portionsArray,
			'options' => $optionsArray,
			'eatInOption' => (bool)$row['eatInOption'],
			'takeAwayOption' => (bool)$row['takeAwayOption'],
			'deliveryOption' => (bool)$row['deliveryOption'],
			'chickenOption' => (bool)$row['chickenOption'],
			'beefOption' => (bool)$row['beefOption'],
			'porkOption' => (bool)$row['porkOption'],
			'fishOption' => (bool)$row['fishOption'],
			'seaFoodOption' => (bool)$row['seaFoodOption'],
			'vegetarianOption' => (bool)$row['vegetarianOption']);


		// array_push($resultArray ,$row);
	}
	// Finally, encode the array to JSON and output the results numerics and pretty

		echo json_encode( $resultArray, JSON_NUMERIC_CHECK | JSON_PRETTY_PRINT );

}
// Close connections
mysqli_close($con);

// https://www.zmrcolombia.com/tableViewJson/restaurantOptionPortion.php?latToSouth=4.728354&latToNorth=4.7363539999999995&lonToWest=-74.056972&lonToEast=-74.04897199999999

?>
